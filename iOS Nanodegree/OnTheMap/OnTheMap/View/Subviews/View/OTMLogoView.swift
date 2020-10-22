//
//  LoginLogoView.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/10/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

class OTMLogoView: UIView {
    
    var image: UIImage? {
        return self.imageView.image
    }
    
    var labelText: String? {
        return self.label.text
    }
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.clear
        iv.contentMode = UIView.ContentMode.scaleAspectFit
        return iv
    }()
    
    private let label: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.white
        lb.textAlignment = NSTextAlignment.center
        lb.font = UIFont(name: "MavenPro-Medium", size: 18)!
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.imageView)
        self.addSubview(self.label)
        self.label.anchor(bottomTo: self.bottomAnchor,
                          leftTo: self.leftAnchor,
                          rightTo: self.rightAnchor)
        self.imageView.anchor(width: 100,
                              topTo: self.topAnchor,
                              bottomTo: self.label.topAnchor,
                              padTop: 20,
                              centerXTo: self.centerXAnchor)
    }
    
    func setImage(image: UIImage?) {
        self.imageView.image = image
    }
    
    func setLabelText(text: String?) {
        self.label.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
