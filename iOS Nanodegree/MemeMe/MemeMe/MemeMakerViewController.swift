//
//  ViewController.swift
//  MemeMe
//
//  Created by Tye Porter on 4/4/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit
import AVFoundation

protocol MemeMakerViewControllerDelegate: AnyObject {
    
    func memeMakerController(_ memeMakerController: MemeMakerViewController, didAddMemeWithObject meme: Meme)
    func memeMakerController(_ memeMakerController: MemeMakerViewController, didFinishEditingWithObject meme: Meme)
    
}

// TODO: Find a way to save font with meme
// TODO: Figure out a way to fix Apple's "Unable to simultaneously satisfy constraints" warnings

class MemeMakerViewController: UIViewController {
    
    enum BarButtonIconType { case title, image, systemImage }

    // MARK: Outlets
    
    var preferredFontNameDictionary = [String: String]()
    weak var delegate: MemeMakerViewControllerDelegate?
    var editingMeme: Meme?
    var isEditingMeme: Bool = false
    var isInInitialEditingState: Bool = true
    
    // Using programmatic views due to unknown bugs in storyboard
    // MARK: Programmatic Views
    
    let topToolbar: UIToolbar = {
        let tb = UIToolbar()
        tb.barTintColor = UIColor.rgb(r: 27, g: 34, b: 39)
        tb.tintColor = UIColor.white
        return tb
    }()
    var shareButtonItem: UIBarButtonItem!
    var cancelSaveButtonItem: UIBarButtonItem!
    
    let bottomToolbar: UIToolbar = {
        let tb = UIToolbar()
        tb.barTintColor = UIColor.rgb(r: 27, g: 34, b: 39)
        tb.tintColor = UIColor.white
        return tb
    }()
    var cameraBarButtonItem: UIBarButtonItem!
    var discardBarButtonItem: UIBarButtonItem!
    
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
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.getFonts()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.addAndAnchorSubviews()
        self.checkIsEditing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isEditingMeme {
            isInInitialEditingState = false
            self.imageView.image = self.editingMeme?.originalImage
            self.updateViewConstraints()
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        self.updateTextFieldsContraints()
   }
    
    func updateTextFieldsContraints() {
        self.topTextField.removeConstraintsFromAllEdges()
        self.bottomTextField.removeConstraintsFromAllEdges()
        self.constrainTextFieldsToContainerView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (_) in
            self.imageView.removeConstraintsFromAllEdges()
            self.containerView.removeConstraintsFromAllEdges()
            self.topToolbar.removeConstraintsFromAllEdges()
            self.bottomToolbar.removeConstraintsFromAllEdges()
            self.addAndAnchorSubviews(reAnchoring: true)
            self.updateTextFieldsContraints()
        }) { (_) in }
    }
        
    // MARK: Actions
    
    @objc func didPressShareButtonItem(_ sender: Any) {
        let memedImage = self.generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)

        activityController.completionWithItemsHandler = {[unowned self](activity: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                return
            }
            
            self.save(memedImage: memedImage)
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
        
        if isEditingMeme {
            self.delegate?.memeMakerController(self, didFinishEditingWithObject: meme)
        } else {
            // Add it to the memes array in the Application Delegate
            let object = UIApplication.shared.delegate
            let appDelegate = object as? AppDelegate
            if let unwrappedAppDelegate = appDelegate { unwrappedAppDelegate.memes.append(meme) }
            
            self.delegate?.memeMakerController(self, didAddMemeWithObject: meme)
        }
    }
    
    @objc func didPressCancelSaveButtonItem(_ sender: Any) {
        if isEditingMeme {
            let memedImage = self.generateMemedImage()
            self.save(memedImage: memedImage)
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func didPressDiscardButtonItem(_ sender: Any) {
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
    
    @objc func didPressAlbumButtonItem(_ sender: Any) {
        self.chooseAnImageFromSource(sourceType: UIImagePickerController.SourceType.photoLibrary)
    }
    
    @objc func didPressCameraButtonItem(_ sender: Any) {
        self.chooseAnImageFromSource(sourceType: UIImagePickerController.SourceType.camera)
    }
    
    func chooseAnImageFromSource(sourceType: UIImagePickerController.SourceType){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func didPressFontButtonItem(_ sender: Any) {
        let fontPickerController = UIFontPickerViewController()
        fontPickerController.delegate = self
        present(fontPickerController, animated: true, completion: nil)
    }
    
    // MARK: Helper Methods
    
    private func setupTextField(textField: UITextField, text: String) {
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
    
    private func setupBarButtonItem(iconType: BarButtonIconType, title: String?, imageName: String?, systemImageName: String?, selector: Selector) -> UIBarButtonItem {
        switch iconType {
        case BarButtonIconType.title:
            return UIBarButtonItem(title: title,
                                   style: UIBarButtonItem.Style.plain,
                                   target: self,
                                   action: selector)
        case BarButtonIconType.image:
            guard let imageName = imageName else { return UIBarButtonItem() }
            return UIBarButtonItem(image: UIImage(named: imageName)?.withRenderingMode(UIImage.RenderingMode.automatic),
                                   style: UIBarButtonItem.Style.plain,
                                   target: self,
                                   action: selector)
        case BarButtonIconType.systemImage:
            guard let systemImageName = systemImageName else { return UIBarButtonItem() }
            return UIBarButtonItem(image: UIImage(systemName: systemImageName)?.withRenderingMode(UIImage.RenderingMode.automatic),
                                   style: UIBarButtonItem.Style.plain,
                                   target: self, action: selector)
        }
    }
    
    private func setupToolbarItems() {
        // Top Toolbar
        self.shareButtonItem = self.setupBarButtonItem(iconType: BarButtonIconType.systemImage,
                                                       title: nil,
                                                       imageName: nil,
                                                       systemImageName: "square.and.arrow.up",
                                                       selector: #selector(didPressShareButtonItem(_:)))
        self.cancelSaveButtonItem = self.setupBarButtonItem(iconType: BarButtonIconType.title,
                                                            title: isEditingMeme ? "Save" : "Cancel",
                                                            imageName: nil,
                                                            systemImageName: nil,
                                                            selector: #selector(didPressCancelSaveButtonItem(_:)))
        self.topToolbar.setItems([
            self.shareButtonItem,
            self.flexibleSpace(),
            self.cancelSaveButtonItem
        ], animated: true)
        self.topToolbar.items?[2].title = isEditingMeme ? "Save" : "Cancel"
        
        // Bottom Toolbar
        self.cameraBarButtonItem = self.setupBarButtonItem(iconType: BarButtonIconType.systemImage,
                                                           title: nil,
                                                           imageName: nil,
                                                           systemImageName: "camera.fill",
                                                           selector: #selector(didPressCameraButtonItem(_:)))
        self.discardBarButtonItem = self.setupBarButtonItem(iconType: BarButtonIconType.systemImage,
                                                            title: nil,
                                                            imageName: nil,
                                                            systemImageName: "trash.fill",
                                                            selector: #selector(didPressDiscardButtonItem(_:)))
        self.bottomToolbar.setItems([
            self.flexibleSpace(),
            self.cameraBarButtonItem,
            self.flexibleSpace(),
            self.setupBarButtonItem(iconType: BarButtonIconType.systemImage,
                                    title: nil,
                                    imageName: nil,
                                    systemImageName: "photo.fill.on.rectangle.fill",
                                    selector: #selector(didPressAlbumButtonItem(_:))),
            self.flexibleSpace(),
            self.discardBarButtonItem,
            self.flexibleSpace(),
            self.setupBarButtonItem(iconType: BarButtonIconType.image,
                                    title: nil,
                                    imageName: "fontIcon",
                                    systemImageName: nil,
                                    selector: #selector(didPressFontButtonItem(_:))),
            self.flexibleSpace()
        ], animated: true)
    }
    
    private func toggleToolbarItems(enabled: Bool) {
        self.shareButtonItem.isEnabled = enabled
        self.discardBarButtonItem.isEnabled = enabled
        if isEditingMeme { self.cancelSaveButtonItem.isEnabled = enabled }
    }
    
    private func flexibleSpace() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
    }
    
    private func resetTextFieldsText() {
        self.topTextField.text = "TOP"
        self.bottomTextField.text = "BOTTOM"
    }
    
    // This method obtains system font names with priority: Black > Heavy > Bold > Regular
    private func getFonts() {
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
    private func addAndAnchorSubviews(reAnchoring: Bool = false) {
        if !reAnchoring {
            self.view.addSubview(self.topToolbar)
            self.view.addSubview(self.bottomToolbar)
            self.view.addSubview(self.containerView)
            self.containerView.addSubview(self.imageView)
            self.containerView.addSubview(self.topTextField)
            self.containerView.addSubview(self.bottomTextField)
        }
        
        self.topToolbar.anchor(topTo: self.view.safeAreaLayoutGuide.topAnchor,
                               leftTo: self.view.leftAnchor,
                               rightTo: self.view.rightAnchor)
        self.bottomToolbar.anchor(bottomTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                                  leftTo: self.view.leftAnchor,
                                  rightTo: self.view.rightAnchor)
        if !reAnchoring {
            self.setupToolbarItems()
            self.cameraBarButtonItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        }
        
        self.containerView.anchor(topTo: self.topToolbar.bottomAnchor,
                                  bottomTo: self.bottomToolbar.topAnchor,
                                  leftTo: self.view.safeAreaLayoutGuide.leftAnchor,
                                  rightTo: self.view.safeAreaLayoutGuide.rightAnchor)
        self.imageView.anchor(topTo: self.containerView.topAnchor,
                              bottomTo: self.containerView.bottomAnchor,
                              leftTo: self.containerView.leftAnchor,
                              rightTo: self.containerView.rightAnchor)
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
    private func calculatePadding() -> (CGFloat, CGFloat) {
        if self.imageView.image != nil {
            // Toggle toolbar items on
            self.toggleToolbarItems(enabled: true)
            
            // Calculate auto layout padding
            let imageFrame = AVMakeRect(aspectRatio: self.imageView.image!.size, insideRect: self.imageView.frame)
            var xSpace = (self.imageView.frame.width - imageFrame.width)
            if xSpace > 0 { xSpace /= 2 }
            var ySpace = (self.imageView.frame.height - imageFrame.height)
            if ySpace > 0 { ySpace /= 2 }
            return (xSpace, ySpace)
        } else {
            // Toggle toolbar items off
            self.toggleToolbarItems(enabled: false)
            
            return (0, 20)
        }
    }
    
    // This method re-constrains text fields to container view
    private func constrainTextFieldsToContainerView() {
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
    private func generateMemedImage() -> UIImage {
        // Hide navbar and toolbar
        self.topToolbar.isHidden = true
        self.bottomToolbar.isHidden = true
        self.view.backgroundColor = UIColor.black
        if self.topTextField.isFirstResponder {
            self.topTextField.resignFirstResponder()
        } else if self.bottomTextField.isFirstResponder {
            self.bottomTextField.resignFirstResponder()
        }
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show navbar and toolbar
        self.topToolbar.isHidden = false
        self.bottomToolbar.isHidden = false
        self.view.backgroundColor = UIColor.rgb(r: 27, g: 34, b: 39)
        
        return memedImage
    }
    
    private func checkIsEditing() {
        if isEditingMeme {
            self.setupTextField(textField: self.topTextField, text: self.editingMeme!.topText)
            self.setupTextField(textField: self.bottomTextField, text: self.editingMeme!.bottomText)
        } else {
            self.setupTextField(textField: self.topTextField, text: "TOP")
            self.setupTextField(textField: self.bottomTextField, text: "BOTTOM")
        }
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

// MARK: - UITextFieldDelegate

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

// MARK: - UIImagePickerControllerDelegate

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

// MARK: - UIFontPickerViewControllerDelegate

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


