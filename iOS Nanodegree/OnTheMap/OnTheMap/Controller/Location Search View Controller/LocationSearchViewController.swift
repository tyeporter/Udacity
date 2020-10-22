//
//  LocationSearchViewController.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/12/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchViewController: UIViewController {
    
    // MARK: Properties
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    weak var delegate: MediaURLViewControllerDelegate?
    
    let searchBar = UISearchBar()
    let tableView = UITableView()
    
    var prePopulatedSearchBarText = ""
    var prePopulatedLinkTextFieldText = ""

    // Navigtaion Bar Height > Normal Navigation Bar Height Due to Search Bar
    // We Need This to Make Proper Adjustments For MediaURLViewController
    var navBarHeight: CGFloat?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: "cellId")
        self.searchCompleter.delegate = self
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.setupSearchCompleter()
        self.setupNavigationBar()
        self.setupTableView()
        self.addAndAnchorSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navBarHeight = self.navigationController?.navigationBar.frame.size.height
    }

    // MARK: - Helper
    private func setupSearchCompleter() {
        // Exclude All Points of Interest
        self.searchCompleter.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll
    }
    
    private func setupTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.otmAshyBlack
        self.tableView.separatorColor = UIColor.otmMediumGray
    }
    
    private func setupNavigationBar() {
        self.searchBar.sizeToFit()
        self.searchBar.showsCancelButton = true
        self.searchBar.tintColor = UIColor.white
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.white
        textFieldInsideUISearchBar?.font = UIFont(name: "MavenPro-Medium", size: 14)!
        self.searchBar.placeholder = "Search Location"
        self.searchBar.text = self.prePopulatedSearchBarText
        navigationItem.titleView = searchBar
    }
    
    private func addAndAnchorSubviews() {
        self.view.addSubview(self.tableView)
        self.tableView.anchor(topTo: self.view.safeAreaLayoutGuide.topAnchor,
                              bottomTo: self.view.bottomAnchor,
                              leftTo: self.view.leftAnchor,
                              rightTo: self.view.rightAnchor)
    }
    
}

// MARK: - UISearchBarDelegate
extension LocationSearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchCompleter.queryFragment = searchText
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension LocationSearchViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DetailTableViewCell
        let searchResult = self.searchResults[indexPath.row]
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.rgb(r: 38, g: 38, b: 38)
        cell.selectedBackgroundView = backgroundView
        cell.backgroundColor = UIColor.rgb(r: 20, g: 20, b: 20)
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let searchResult = self.searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchResult.title
        
        let mediaUrlVC = MediaURLViewController()
        mediaUrlVC.delegate = self.delegate
        searchRequest.region = mediaUrlVC.mapView.region
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response: MKLocalSearch.Response?, error: Error?) in
            if let response = response {
                if response.mapItems.count > 0 {
                    let coordinate = response.mapItems[0].placemark.coordinate
                    let lat = coordinate.latitude
                    let lon = coordinate.longitude
                    let region = MKCoordinateRegion(
                        center: CLLocationCoordinate2DMake(lat, lon), latitudinalMeters: 12500, longitudinalMeters: 12500);
                    mediaUrlVC.mapItem = response.mapItems[0]
                    mediaUrlVC.region = region
                }
            }
        }
        
        self.searchBar.resignFirstResponder()
        mediaUrlVC.searchNavBarHeight = self.navBarHeight
        mediaUrlVC.prePopulatedLinkTextFieldText = self.prePopulatedLinkTextFieldText
        self.navigationController?.pushViewController(mediaUrlVC, animated: true)
    }

}

// MARK: - MKLocalSearchCompleterDelegate
extension LocationSearchViewController: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let digitsCharacterSet = NSCharacterSet.decimalDigits

        // Remove Results with Digits and/or Subtitles
        let filteredResults = completer.results.filter { result in
            if result.title.rangeOfCharacter(from: digitsCharacterSet) != nil || result.subtitle != "" {
                return false
            }
            return true
        }
        
        self.searchResults = filteredResults
        self.tableView.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("error")
    }

}
