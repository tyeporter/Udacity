//
//  OTMSnackBar.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/14/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

class OTMSnackBar: UIView {
    
    // MARK: Properties
    var text: String? {
        didSet {
            self.label.text = text
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: "MavenPro-Medium", size: 14)!
        label.textAlignment = NSTextAlignment.center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.otmDarkGray
        self.addAndAnchorSubviews()
        self.layer.cornerRadius = 9
    }
    
    private func addAndAnchorSubviews() {
        self.addSubview(self.label)
        self.label.anchor(topTo: self.topAnchor,
                          bottomTo: self.bottomAnchor,
                          leftTo: self.leftAnchor,
                          rightTo: self.rightAnchor,
                          padTop: 15, padBottom: 15, padLeft: 20, padRight: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
