//
//  ViewController.swift
//  MemeMe
//
//  Created by Tye Porter on 4/4/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit
import AVFoundation

class MemeMakerViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var shareButtonItem: UIBarButtonItem!
    @IBOutlet weak var discardButtonItem: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cameraBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var fontBarButtonItem: UIBarButtonItem! {
        didSet {
            fontBarButtonItem.image = UIImage(named: "fontIcon")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
    }
    var preferredFontNameDictionary = [String: String]()
    
    // MARK: Programmatic Views
    
    let containerView: UIView = {
        let v = UIView()
        return v
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = UIView.ContentMode.scaleAspectFit
        return iv
    }()
    
    let topTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 1
        return tf
    }()
    
    let bottomTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 2
        return tf
    }()
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.getFonts()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.cameraBarButtonItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        
        self.setupTextField(textField: self.topTextField, text: "TOP")
        self.setupTextField(textField: self.bottomTextField, text: "BOTTOM")
        
        self.addAndAnchorSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override func updateViewConstraints() {
       super.updateViewConstraints()
       self.topTextField.removeConstraintsFromAllEdges()
       self.bottomTextField.removeConstraintsFromAllEdges()
       self.constrainTextFieldsToContainerView()
   }
    
    // MARK: Actions
    
    @IBAction func shareMeme(_ sender: Any) {
        let memedImage = self.generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {[weak self](activity: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                return
            }
            print("Saving")
            self?.save(memedImage: memedImage)
        }
        
        // iPad needs BarButtonItem or SourceView
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            if activityController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                activityController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
            }
        }
        
        present(activityController, animated: true, completion: nil)
    }
    
    func save(memedImage: UIImage) {
        // Create the meme
        let meme = Meme(topText: self.topTextField.text!, bottomText: self.bottomTextField.text!, originalImage: self.imageView.image!, memedImage: memedImage)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as? AppDelegate
        if let appDel = appDelegate { appDel.memes.append(meme) }
    }
    
    @IBAction func dismissMemeVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func discardImage(_ sender: Any) {
        imageView.image = nil
        self.updateViewConstraints()
        self.changeFont(of: [self.topTextField, self.bottomTextField], with: "HelveticaNeue-CondensedBlack")
        self.resetTextFieldsText()
        
        // If user discards image while editing text, hide keyboard
        if self.topTextField.isFirstResponder {
            self.topTextField.resignFirstResponder()
        } else if self.bottomTextField.isFirstResponder {
            self.bottomTextField.resignFirstResponder()
        }
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        self.chooseAnImageFromSource(sourceType: UIImagePickerController.SourceType.photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        self.chooseAnImageFromSource(sourceType: UIImagePickerController.SourceType.camera)
    }
    
    func chooseAnImageFromSource(sourceType: UIImagePickerController.SourceType){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func changeFont(_ sender: Any) {
        let fontPickerController = UIFontPickerViewController()
        fontPickerController.delegate = self
        present(fontPickerController, animated: true, completion: nil)
    }
    
    // MARK: Helper Methods
    
    func setupTextField(textField: UITextField, text: String) {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -3.0,
         ]
                
        textField.defaultTextAttributes = memeTextAttributes
        textField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        textField.minimumFontSize = 12
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = NSTextAlignment.center
        textField.text = text
        textField.delegate = self
    }
    
    func resetTextFieldsText() {
        self.topTextField.text = "TOP"
        self.bottomTextField.text = "BOTTOM"
    }
    
    // This method obtains system font names with priority: Black > Heavy > Bold > Regular
    func getFonts() {
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            for name in names {
                if name.passesFontConditionTest(with: String.FontCondition.isBlack)  {
                    self.preferredFontNameDictionary[family] = name
                } else if name.passesFontConditionTest(with: String.FontCondition.isHeavy) {
                    if self.preferredFontNameDictionary[family] == nil {
                        self.preferredFontNameDictionary[family] = name
                    }
                } else if name.passesFontConditionTest(with: String.FontCondition.isBold)  {
                    if self.preferredFontNameDictionary[family] == nil {
                        self.preferredFontNameDictionary[family] = name
                    }
                } else if name.passesFontConditionTest(with: String.FontCondition.isRegular) {
                    if self.preferredFontNameDictionary[family] == nil {
                        self.preferredFontNameDictionary[family] = name
                    }
                }
            }
        }
    }
    
    // This method adds and anchors the programmatic views to the view
    func addAndAnchorSubviews() {
        self.view.addSubview(self.containerView)
        self.containerView.anchor(topTo: self.topToolbar.bottomAnchor,
                                  bottomTo: self.bottomToolbar.topAnchor,
                                  leftTo: self.view.safeAreaLayoutGuide.leftAnchor,
                                  rightTo: self.view.safeAreaLayoutGuide.rightAnchor)
        
        self.containerView.addSubview(self.imageView)
        self.imageView.anchor(topTo: self.containerView.topAnchor,
                              bottomTo: self.containerView.bottomAnchor,
                              leftTo: self.containerView.leftAnchor,
                              rightTo: self.containerView.rightAnchor)
        
        self.containerView.addSubview(self.topTextField)
        self.containerView.addSubview(self.bottomTextField)
        self.topTextField.anchor(topTo: self.containerView.topAnchor,
                                 leftTo: self.containerView.leftAnchor,
                                 rightTo: self.containerView.rightAnchor,
                                 padTop: 20)
        
        self.bottomTextField.anchor(bottomTo: self.containerView.bottomAnchor,
                                    leftTo: self.containerView.leftAnchor,
                                    rightTo: self.containerView.rightAnchor,
                                    padBottom: 20)
    }
    
    // This method calculates padding/spacing for text fields
    func calculatePadding() -> (CGFloat, CGFloat) {
        if self.imageView.image != nil {
            // Toggle nav bar items on
            self.shareButtonItem.isEnabled = true
            self.discardButtonItem.isEnabled = true
            
            // Calculate auto layout padding
            let imageFrame = AVMakeRect(aspectRatio: self.imageView.image!.size, insideRect: self.imageView.frame)
            var xSpace = (self.imageView.frame.width - imageFrame.width)
            if xSpace > 0 { xSpace /= 2 }
            var ySpace = (self.imageView.frame.height - imageFrame.height)
            if ySpace > 0 { ySpace /= 2 }
            return (xSpace, ySpace)
        } else {
            // Toggle nav bar items off
            self.shareButtonItem.isEnabled = false
            self.discardButtonItem.isEnabled = false
            
            return (0, 20)
        }
    }
    
    // This method re-constrains text fields to container view
    func constrainTextFieldsToContainerView() {
        let (xAxisPadding, yAxisPadding) = self.calculatePadding()
        let imageViewHasImage = self.imageView.image != nil
        self.topTextField.anchor(topTo: self.containerView.topAnchor,
                                 leftTo: self.containerView.leftAnchor,
                                 rightTo: self.containerView.rightAnchor,
                                 padTop: imageViewHasImage ? yAxisPadding + 20 : yAxisPadding,
                                 padLeft: xAxisPadding,
                                 padRight: xAxisPadding)
        self.bottomTextField.anchor(bottomTo: self.containerView.bottomAnchor,
                                    leftTo: self.containerView.leftAnchor,
                                    rightTo: self.containerView.rightAnchor,
                                    padBottom: imageViewHasImage ? yAxisPadding + 20 : yAxisPadding,
                                    padLeft: xAxisPadding,
                                    padRight: xAxisPadding)
    }
    
    // This method generates the meme image
    func generateMemedImage() -> UIImage {
        // Hide navbar and toolbar
        let topToolbarFrame = self.topToolbar.frame
        let bottomToolbarFrame = self.bottomToolbar.frame
        self.topToolbar.frame = CGRect(x: -topToolbarFrame.size.width, y: topToolbarFrame.origin.y, width: topToolbarFrame.size.width, height: topToolbarFrame.size.height)
        self.bottomToolbar.frame = CGRect(x: -bottomToolbarFrame.size.width, y: bottomToolbarFrame.origin.y, width: bottomToolbarFrame.size.width, height: bottomToolbarFrame.size.height)
        self.view.backgroundColor = UIColor.black
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show navbar and toolbar
        self.topToolbar.frame = CGRect(x: topToolbarFrame.origin.x, y: topToolbarFrame.origin.y, width: topToolbarFrame.size.width, height: topToolbarFrame.size.height)
        self.bottomToolbar.frame = CGRect(x: bottomToolbarFrame.origin.x, y: bottomToolbarFrame.origin.y, width: bottomToolbarFrame.size.width, height: bottomToolbarFrame.size.height)
        self.view.backgroundColor = UIColor.rgb(r: 27, g: 34, b: 39)
        
        return memedImage
    }
    
    // MARK: Keyboard Notifications
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboarWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboarWillShow(_ notification: NSNotification) {
        let keyboardHeight = getKeyboardHeight(notification)
        let bottomTextFieldWillBeBlocked = keyboardHeight > (self.view.safeAreaInsets.bottom + self.bottomToolbar.frame.height + self.calculatePadding().0)
        if bottomTextFieldWillBeBlocked && self.bottomTextField.isEditing {
            self.view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        
        if let kbSize = keyboardSize {
            return kbSize.cgRectValue.height
        } else {
            return 0
        }
    }
}

// MARK: - Removing Constraints

extension UIView {
    func removeConstraintsFromAllEdges(){
        if let superview = self.superview {
            for constraint in superview.constraints {
                if let firstItem = constraint.firstItem, firstItem === self {
                    superview.removeConstraint(constraint)
                }

                if let secondItem = constraint.secondItem, secondItem === self {
                    superview.removeConstraint(constraint)
                }
            }
        }
    }
}

// MARK: - Text Field Delegate

extension MemeMakerViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" && textField.tag == 1 {
            textField.text = "TOP"
        } else if textField.text == "" && textField.tag == 2 {
            textField.text = "BOTTOM"
        }
    }
}

// MARK: - Image Picker Controller Delegate

extension MemeMakerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.imageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.imageView.image = originalImage
        }
        
        self.updateViewConstraints()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Font Picker View Controller Delegate

extension MemeMakerViewController: UIFontPickerViewControllerDelegate {
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        if let descriptor = viewController.selectedFontDescriptor {
            if let family = descriptor.fontAttributes[UIFontDescriptor.AttributeName.family] as? String {
                self.changeFont(of: [self.topTextField, self.bottomTextField], with: family)
            }
        }
    }
        
    func changeFont(of textFields: [UITextField], with family: String) {
        for tf in textFields {
            let memeTextAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.strokeColor: UIColor.black,
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont(name: self.preferredFontNameDictionary[family] ?? family, size: 40)!,
                NSAttributedString.Key.strokeWidth: -3.0,
             ]
                    
            tf.defaultTextAttributes = memeTextAttributes
            tf.textAlignment = NSTextAlignment.center
        }
    }
}


