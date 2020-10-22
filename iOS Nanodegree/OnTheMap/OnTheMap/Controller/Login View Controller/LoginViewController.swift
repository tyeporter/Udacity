//
//  ViewController.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/10/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: AnyObject {
    func didDismiss(_ viewController: UIViewController)
}
// TODO: IMPLEMENT SIGN UP BUTTON
// TODO: PERSIST USER LOGIN / SESSION DATA
class LoginViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Properties
    weak var delegate: LoginViewControllerDelegate?
        
    let loginLogoView = OTMLogoView()
    let emailTextField = OTMTextField()
    let passwordTextField = OTMTextField()
    let loginButton = OTMButton()
    let signUpButton = OTMButton()
    let snackbar = OTMSnackBar()
    let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.6
        return view
    }()
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    var bottomSpace: CGFloat = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.otmLightGray
        self.addAndAnchorSubviews()
        self.setupFormElements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.bottomSpace = self.view.frame.maxY - self.signUpButton.frame.maxY
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - Actions / Events
    @objc func signUpButtonPressed(_ button: UIButton) {
        guard let url = URL(string: "https://auth.udacity.com/sign-up") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc func loginButtonPressed(_ button: UIButton) {
        _ = self.emailTextField.resignFirstResponder()
        _ = self.passwordTextField.resignFirstResponder()
        self.setLogginIn(true)
        // Try to Create Session
        UdacityClient.createSession(username: self.emailTextField.text!, password: self.passwordTextField.text!, completionHandler: self.handleSessionResponse(success:error:))
    }
    
    func handleSessionResponse(success: Bool, error: Error?) {
        self.setLogginIn(false)
        if success {
            // Dismiss if Session Creation Succeeds
            self.dismiss(animated: true, completion: nil)
            self.delegate?.didDismiss(self)
        } else {
            // Show Snackbar with Useful Information
            self.snackbar.text = "Unsuccessful Login Attempt. Try Again."
            self.showSnackbar()
        }
    }
    
    // MARK: - Keyboard Notifications
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
        let signUpWillBeBlocked = keyboardHeight > bottomSpace
        if signUpWillBeBlocked {
            self.view.frame.origin.y = -(keyboardHeight - bottomSpace)
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

    // MARK: - Helper
    private func showSnackbar() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: { [unowned self] in
            self.snackbar.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 3, options: UIView.AnimationOptions.curveEaseOut, animations: { [unowned self] in
                self.snackbar.alpha = 0
            }, completion: nil)
        }
    }
    
    private func setLogginIn(_ loggingIn: Bool) {
        if loggingIn { // User is Logging In
            self.overlayView.isHidden = false
            self.activityIndicator.startAnimating()
        } else {
            self.overlayView.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func addAndAnchorSubviews() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField])
        stackView.backgroundColor = UIColor.brown
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.spacing = 10
        stackView.distribution = UIStackView.Distribution.fillEqually
        self.view.addSubview(stackView)
        stackView.anchor(height: 120,
                         leftTo: self.view.leftAnchor,
                         rightTo: self.view.rightAnchor,
                         padLeft: 25, padRight: 25,
                         centerYTo: self.view.centerYAnchor)
        self.view.addSubview(self.loginLogoView)
        self.loginLogoView.anchor(topTo: self.view.safeAreaLayoutGuide.topAnchor,
                                  bottomTo: stackView.topAnchor,
                                  leftTo: self.view.leftAnchor,
                                  rightTo: self.view.rightAnchor,
                                  padBottom: 25)
        self.view.addSubview(self.loginButton)
        self.loginButton.anchor(height: 50,
                                topTo: stackView.bottomAnchor,
                                leftTo: stackView.leftAnchor,
                                rightTo: stackView.rightAnchor,
                                padTop: 10)
        self.view.addSubview(self.signUpButton)
        self.signUpButton.anchor(height: 50,
                                 topTo: self.loginButton.bottomAnchor,
                                 leftTo: self.loginButton.leftAnchor,
                                 rightTo: self.loginButton.rightAnchor,
                                 padTop: 10)
        
        self.view.addSubview(self.snackbar)
        self.snackbar.anchor(height: 75,
                             bottomTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                             leftTo: self.view.leftAnchor,
                             rightTo: self.view.rightAnchor,
                             padLeft: 25, padRight: 25)
        
        self.view.addSubview(self.overlayView)
        self.overlayView.addSubview(self.activityIndicator)
        self.overlayView.anchor(topTo: self.view.topAnchor,
                                bottomTo: self.view.bottomAnchor,
                                leftTo: self.view.leftAnchor,
                                rightTo: self.view.rightAnchor)
        self.activityIndicator.anchor(centerXTo: self.overlayView.centerXAnchor,
                                      centerYTo: self.overlayView.centerYAnchor)
        self.overlayView.isHidden = true
    }
    
    private func setupFormElements() {
        // Login Logo View
        self.loginLogoView.setImage(image: UIImage(named: "udacity_logo"))
        self.loginLogoView.setLabelText(text: "Login to Udacity")
                
        // Email Text Field
        self.emailTextField.placeholder = "Email"
        self.emailTextField.icon = UIImage(named: "email")
        
        // Password Text Field
        self.passwordTextField.placeholder = "Password"
        self.passwordTextField.isSecureTextEntry = true
        self.passwordTextField.icon = UIImage(named: "password")
        
        // Login Button
        self.loginButton.setTitle("Login", for: UIControl.State.normal)
        self.loginButton.buttonColor = UIColor.rgb(r: 20, g: 20, b: 20)
        self.loginButton.addTarget(self, action: #selector(loginButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        // Sign Up Button
        self.signUpButton.backgroundColor = UIColor.clear
        self.signUpButton.buttonColor = UIColor.clear
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?   ", attributes: [
            NSAttributedString.Key.font: UIFont(name: "MavenPro-Regular", size: 16)!,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [
            NSAttributedString.Key.font : UIFont(name: "MavenPro-Bold", size: 16)!,
            NSAttributedString.Key.foregroundColor: UIColor.udacityBlue
        ]))
        self.signUpButton.setAttributedTitle(attributedTitle, for: UIControl.State.normal)
        self.signUpButton.addTarget(self, action: #selector(self.signUpButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        self.snackbar.alpha = 0
    }

}
