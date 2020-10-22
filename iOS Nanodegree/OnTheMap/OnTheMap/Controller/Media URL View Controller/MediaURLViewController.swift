//
//  MediaURLViewController.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/13/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit
import MapKit

protocol MediaURLViewControllerDelegate: AnyObject {
    func didSubmit()
}

class MediaURLViewController: UIViewController {
    
    // MARK: Properties
    let mapView = MKMapView()
    var mapItem: MKMapItem?
    var region: MKCoordinateRegion?
    weak var delegate: MediaURLViewControllerDelegate?
    
    let userLinkContainerView = UIView()
    let linkTextField = OTMTextField()
    let submitButton = OTMButton()
        
    var prePopulatedLinkTextFieldText = ""
    var searchNavBarHeight: CGFloat?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addAndAnchorSubviews()
        if let region = region {
            self.mapView.setRegion(region, animated: true)
            self.setupAnnotationsForMap()
            self.mapView.isUserInteractionEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = self.linkTextField.resignFirstResponder()
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - Actions / Events
    @objc func submitButtonPressed(_ button: UIButton) {
        _ = self.linkTextField.resignFirstResponder()
        guard let location = mapItem?.placemark.title else { return }
        guard let lat = mapItem?.placemark.coordinate.latitude else { return }
        guard let lon = mapItem?.placemark.coordinate.longitude else { return }
        let mediaURL = self.linkTextField.text ?? ""
        if UdacityClient.Auth.shareLocationType == UdacityClient.ShareLocationType.create {
            UdacityClient.postStudentLocation(locationString: location, mediaURL: mediaURL, latitude: lat, longitude: lon, completionHandler: self.handlePostStudentLocation(success:error:))
        } else if UdacityClient.Auth.shareLocationType == UdacityClient.ShareLocationType.update {
            UdacityClient.putStudentLocation(locationString: location, mediaURL: mediaURL, latitude: lat, longitude: lon, completionHandler: self.handlePutStudentLocation(success:error:))
        }
    }
    
    func handlePutStudentLocation(success: Bool, error: Error?) {
        if success {
            print("Successfully updated student location. Safe to reload data!")
            self.dismiss(animated: true, completion: nil)
            self.delegate?.didSubmit()
        }
    }
    
    func handlePostStudentLocation(success: Bool, error: Error?) {
        if success {
            print("Successfully created student location. Safe to reload data!")
            self.dismiss(animated: true, completion: nil)
            self.delegate?.didSubmit()
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
        let submitWillBeBlocked = self.userLinkContainerView.frame.maxY > (self.view.frame.height - keyboardHeight)
        if submitWillBeBlocked {
            // Spacing We Have to Account For
            let safeAreaSpacing = self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom
            let navBarSpacing = self.searchNavBarHeight! - (self.navigationController?.navigationBar.frame.size.height)!
            
            // Make Changes
            self.view.frame.origin.y = -(keyboardHeight - safeAreaSpacing - (self.navigationController?.navigationBar.frame.size.height)! - navBarSpacing)
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        // Spacing We Have to Account For
        let safeAreaSpacing = self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom
        let navBarSpacing = self.searchNavBarHeight! - (self.navigationController?.navigationBar.frame.size.height)!
        
        // Make Changes
        self.view.frame.origin.y = 0 + safeAreaSpacing + (self.navigationController?.navigationBar.frame.size.height)! + navBarSpacing
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
    private func setupAnnotationsForMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = region!.center
        self.mapView.addAnnotation(annotation)
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationItem.leftBarButtonItem?.title = "Choose Location"
    }
    
    @objc func backBarButtonItemPressed(_ barButtonItem: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func addAndAnchorSubviews() {
        let bottomSafeAreaView = UIView()
        bottomSafeAreaView.backgroundColor = UIColor.otmMediumGray
        self.view.addSubview(bottomSafeAreaView)
        bottomSafeAreaView.anchor(height: self.view.safeAreaInsets.bottom,
                                  bottomTo: self.view.bottomAnchor,
                                  leftTo: self.view.leftAnchor,
                                  rightTo: self.view.rightAnchor)
        
        self.view.addSubview(self.mapView)
        self.mapView.anchor(topTo: self.view.safeAreaLayoutGuide.topAnchor,
                            bottomTo: bottomSafeAreaView.topAnchor,
                            leftTo: self.view.leftAnchor,
                            rightTo: self.view.rightAnchor)
        
        userLinkContainerView.backgroundColor = UIColor.otmMediumGray
        self.view.addSubview(userLinkContainerView)
        userLinkContainerView.anchor(height: 125,
                                     bottomTo: self.mapView.bottomAnchor,
                                     leftTo: self.mapView.leftAnchor,
                                     rightTo: self.mapView.rightAnchor)
        
        let locationLabel = UILabel()
        locationLabel.text = "Enter a Link to Share"
        locationLabel.font = UIFont(name: "MavenPro-Bold", size: 16)!
        locationLabel.textColor = UIColor.white
        locationLabel.textAlignment = NSTextAlignment.center
        userLinkContainerView.addSubview(locationLabel)
        locationLabel.anchor(topTo: userLinkContainerView.topAnchor,
                             leftTo: userLinkContainerView.leftAnchor,
                             rightTo: userLinkContainerView.rightAnchor,
                             padTop: 10, padLeft: 10, padRight: 10)
        
        self.linkTextField.placeholder = "Link to Website"
        self.linkTextField.text = self.prePopulatedLinkTextFieldText
        self.linkTextField.icon = UIImage(named: "link")
        userLinkContainerView.addSubview(self.linkTextField)
        self.linkTextField.anchor(width: 250, height: 35,
                                  topTo: locationLabel.bottomAnchor,
                                  padTop: 10,
                                  centerXTo: userLinkContainerView.centerXAnchor)
        
        self.submitButton.setTitle("Submit", for: UIControl.State.normal)
        self.submitButton.buttonColor = UIColor.otmAshyBlack
        self.submitButton.addTarget(self, action: #selector(submitButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        userLinkContainerView.addSubview(self.submitButton)
        self.submitButton.anchor(width: 75,
                                 topTo: self.linkTextField.bottomAnchor,
                                 bottomTo: userLinkContainerView.bottomAnchor,
                                 padTop: 5, padBottom: 5,
                                 centerXTo: userLinkContainerView.centerXAnchor)
    }

}

// MARK: - MKMapViewDelegate
extension MediaURLViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.pinTintColor = UIColor.udacityBlue
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
}
