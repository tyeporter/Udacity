//
//  DetailTableViewCell.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/12/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        self.textLabel?.font = UIFont(name: "MavenPro-Medium", size: 16)!
        self.detailTextLabel?.font = UIFont(name: "MavenPro-Medium", size: 14)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
