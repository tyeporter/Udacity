//
//  HomeViewController.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/12/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController {
        
    // MARK: Properties
    var userLocation: StudentLocationCodable?
    var userIsOnMap: Bool = false

    let loginViewController = LoginViewController()
    let mapViewController = MapViewController()
    let listViewController = ListViewController()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.loginViewController.delegate = self
        self.setupNavigationBar()
        self.setupTabs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Check to See If User is Logged In
        checkSession()
    }
    
    // MARK: - Actions / Events
    @objc func addLocationBarButtonItemPressed(_ barButtonItem: UIBarButtonItem) {
        if userIsOnMap {
            // Create an Alert Controller to Inform the User That
            // They Are Going to Overwrite Their Current Location
            let alertMessage = "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?"
            let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
            let overwriteAction = UIAlertAction(title: "Overwrite", style: UIAlertAction.Style.default) { (_) in
                // Present Location Search Controller
                let locationSearchVC = LocationSearchViewController()
                locationSearchVC.delegate = self
                locationSearchVC.prePopulatedSearchBarText = StudentLocationModel.locations[0].mapString
                locationSearchVC.prePopulatedLinkTextFieldText = StudentLocationModel.locations[0].mediaURL
                let searchController = LightContentNavigationController(rootViewController: locationSearchVC)
                searchController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
                self.present(searchController, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(overwriteAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            // Present Location Search Controller
            let locationSearchVC = LocationSearchViewController()
            locationSearchVC.delegate = self
            let searchController = LightContentNavigationController(rootViewController: locationSearchVC)
            searchController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
            self.present(searchController, animated: true, completion: nil)
        }
    }
    
    @objc func logoutBarButtonItemPressed(_ barButtonItem: UIBarButtonItem) {
        UdacityClient.deleteSession(completionHandler: self.handleDeleteSessionResponse(success:error:))
    }
    
    func handleDeleteSessionResponse(success: Bool, error: Error?) {
        if success {
            self.checkSession()
        }
    }
    
    // MARK: - Helper
    private func checkSession() {
        if UdacityClient.Auth.sessionId == "" { // `sessionId` Was Not Set
            // Show Login Controller So User Can Login
            loginViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.present(loginViewController, animated: false, completion: nil)
        }
    }
    
    func handleGetStudentLocationsReponse(studentLocations: [StudentLocationCodable], error: Error?) {
        if error == nil { // Fetch was Successful
            // Append All Student Location to `locations` Array
            StudentLocationModel.locations += studentLocations
            
            // Setup the Map View and the Table View
            self.mapViewController.setupAnnotationsForMap()
            self.listViewController.tableView.reloadData()
        }
    }
    
    func handleGetUserLocationResponse(studentLocations: [StudentLocationCodable], error: Error?) {
        // Reset Locations
        StudentLocationModel.locations = []
        
        if studentLocations.count > 0 { // User is On Map
            userLocation = studentLocations[0]
            self.userIsOnMap = true
            
            // Set Sharing Type to `.update` and Append User Location to `locations` Array
            UdacityClient.Auth.shareLocationType = UdacityClient.ShareLocationType.update
//            StudentLocationModel.locations.append(userLocation!)
        } else {
            self.userIsOnMap = false
        }
        // Fetch All Student Locations
        UdacityClient.getStudentLocations(completionHandler: self.handleGetStudentLocationsReponse(studentLocations:error:))
    }
    
    func handleGetUserDataResponse(success: Bool, error: Error?) {
        if success {
            // Set `title` of View Controller and Check For / Fetch User Location
            self.navigationItem.title = "\(UdacityClient.Auth.firstName) \(UdacityClient.Auth.lastName)"
            UdacityClient.getUserLocation(uniqueKey: UdacityClient.Auth.accountKey, completionHandler: self.handleGetUserLocationResponse(studentLocations:error:))
        }
    }
    
    private func setupTabs() {
        let vc1 = mapViewController
        let vc2 = listViewController
        vc1.tabBarItem = UITabBarItem(title: "Map", image: UIImage(named: "map"), tag: 0)
        vc2.tabBarItem = UITabBarItem(title: "List", image: UIImage(named: "list"), tag: 1)
        self.viewControllers = [ vc1, vc2 ]
    }
    
    private func setupNavigationBar() {
        let addLocationItemImage = UIImage(named: "add_location")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        let addLocationBarButtonItem = UIBarButtonItem(image: addLocationItemImage,
                                                       style: UIBarButtonItem.Style.plain,
                                                       target: self,
                                                       action: #selector(addLocationBarButtonItemPressed(_:)))
        self.navigationItem.leftBarButtonItem = addLocationBarButtonItem
        
        let logoutItemImage = UIImage(named: "logout")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        let logoutBarButtonItem = UIBarButtonItem(image: logoutItemImage,
                                                          style: UIBarButtonItem.Style.plain,
                                                          target: self,
                                                          action: #selector(logoutBarButtonItemPressed(_:)))
        self.navigationItem.rightBarButtonItem = logoutBarButtonItem
    }

}

// MARK: - LoginViewControllerDelegate
extension HomeViewController: LoginViewControllerDelegate {
    
    func didDismiss(_ viewController: UIViewController) {
        // Fetch User Data
        UdacityClient.getUserData(completionHandler: self.handleGetUserDataResponse(success:error:))
    }
    
}

extension HomeViewController: MediaURLViewControllerDelegate {
    
    func didSubmit() {
        // Re-Fetch User Location (-> Update the `locations` Array -> Update Map View & Table View)
        UdacityClient.getUserLocation(uniqueKey: UdacityClient.Auth.accountKey, completionHandler: self.handleGetUserLocationResponse(studentLocations:error:))
    }
    
}
