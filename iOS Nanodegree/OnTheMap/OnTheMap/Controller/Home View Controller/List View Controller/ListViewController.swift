//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/12/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    // MARK: Properties
    var userIsOnMap: Bool = false
    
    let tableView = UITableView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: "cellId")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.setupTableView()
        self.addAndAnchorSubviews()
    }
    
    // MARK: - Helper
    private func setupTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.rgb(r: 20, g: 20, b: 20)
        self.tableView.separatorColor = UIColor.rgb(r: 38, g: 38, b: 38)
    }
    
    private func addAndAnchorSubviews() {
        self.view.addSubview(self.tableView)
        self.tableView.anchor(topTo: self.view.topAnchor,
                              bottomTo: self.view.bottomAnchor,
                              leftTo: self.view.leftAnchor,
                              rightTo: self.view.rightAnchor)
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocationModel.locations.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DetailTableViewCell

        let student = StudentLocationModel.locations[indexPath.row]
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.otmMediumGray
        cell.selectedBackgroundView = backgroundView
        cell.backgroundColor = UIColor.otmAshyBlack
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.lightGray
        cell.imageView?.tintColor = UIColor.udacityBlue
        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mediaURL

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let studentLocation = StudentLocationModel.locations[indexPath.row]
        let urlString = studentLocation.mediaURL
        guard let url = URL(string: urlString) else {
            print("unable to convert mediaURL string to URL")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}
