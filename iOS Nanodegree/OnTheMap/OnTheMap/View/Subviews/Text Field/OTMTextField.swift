//
//  LoginTextField.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/10/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

class OTMTextField: UIView {
    
    // MARK: Properties
    var placeholder: String? {
        didSet {
            self.setPlaceholderText(text: placeholder)
        }
    }
    
    var text: String? {
        get {
            return self.textField.text
        }
        
        set {
            self.textField.text = newValue
        }
        
    }
    
    var icon: UIImage? {
        didSet {
            self.imageView.image = icon
        }
    }
    
    var isSecureTextEntry: Bool? {
        didSet { self.textField.isSecureTextEntry = isSecureTextEntry ?? false }
    }
    
    private let imageViewContainer: UIView = {
        let ivc = UIView()
        ivc.backgroundColor = UIColor.clear
        return ivc
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = UIView.ContentMode.scaleAspectFit
        iv.tintColor = UIColor.lightGray
        return iv
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.textColor = UIColor.white
        tf.borderStyle = UITextField.BorderStyle.none
        tf.font = UIFont(name: "MavenPro-Medium", size: 16)!
        tf.addTarget(self, action: #selector(didEditTextField), for: UIControl.Event.editingChanged)
        return tf
    }()
    
    private let clearButtonContainer: UIView = {
        let ivc = UIView()
        ivc.backgroundColor = UIColor.clear
        return ivc
    }()
    
    private let clearButton: UIButton = {
        let bt = UIButton()
        bt.tintColor = UIColor.lightGray
        bt.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        bt.setImage(UIImage(named: "clear"), for: UIControl.State.normal)
        bt.addTarget(self, action: #selector(didPressClearButton), for: UIControl.Event.touchUpInside)
        bt.alpha = 0
        return bt
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.otmDarkGray
        self.isSecureTextEntry = false
        self.textField.delegate = self
        self.addAndAnchorSubviews()
    }
    
    // MARK: - Actions
    @objc func didEditTextField(_ textField: UITextField) {
        if textField.text != "" {
            self.clearButton.alpha = 1
        } else {
            self.clearButton.alpha = 0
        }
    }
    
    @objc func didPressClearButton(_ button: UIButton) {
        self.textField.text = ""
        button.alpha = 0
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        self.textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Helper
    private func setPlaceholderText(text: String?) {
        let attributedString = NSAttributedString(string: text ?? "", attributes: [
            NSAttributedString.Key.font: UIFont(name: "MavenPro-Medium", size: 16)!,
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ])
        self.textField.attributedPlaceholder = attributedString
    }
    
    private func addAndAnchorSubviews() {
        self.addSubview(self.imageViewContainer)
        self.imageViewContainer.anchor(width: 30,
                                       topTo: self.topAnchor,
                                       bottomTo: self.bottomAnchor,
                                       leftTo: self.leftAnchor)
        self.imageViewContainer.addSubview(self.imageView)
        self.imageView.anchor(topTo: self.imageViewContainer.topAnchor,
                              bottomTo: self.imageViewContainer.bottomAnchor,
                              leftTo: self.imageViewContainer.leftAnchor,
                              rightTo: self.imageViewContainer.rightAnchor,
                              padLeft: 5, padRight: 5)
                
        self.addSubview(self.clearButtonContainer)
        self.clearButtonContainer.anchor(width: 30,
                                         topTo: self.topAnchor,
                                         bottomTo: self.bottomAnchor,
                                         rightTo: self.rightAnchor)
        self.clearButtonContainer.addSubview(self.clearButton)
        self.clearButton.anchor(topTo: self.clearButtonContainer.topAnchor,
                              bottomTo: self.clearButtonContainer.bottomAnchor,
                              leftTo: self.clearButtonContainer.leftAnchor,
                              rightTo: self.clearButtonContainer.rightAnchor,
                              padLeft: 5, padRight: 5)
        
        self.addSubview(self.textField)
        self.textField.anchor(topTo: self.topAnchor,
                              bottomTo: self.bottomAnchor,
                              leftTo: self.imageView.rightAnchor,
                              rightTo: clearButton.leftAnchor,
                              padLeft: 5)
        self.textField.autocapitalizationType = UITextAutocapitalizationType.none
        self.textField.autocorrectionType = UITextAutocorrectionType.no
    }

    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UITextFieldDelegate
extension OTMTextField: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.clearButton.alpha = 0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text != "" && textField.text != nil {
            self.clearButton.alpha = 1
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.clearButton.alpha = 0
        textField.resignFirstResponder()
        return true
    }
    
}
