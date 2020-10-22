//
//  NoImagesOverlayView.swift
//  VirtualTourist
//
//  Created by Tye Porter on 6/2/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

class NoImagesOverlayView: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.heavy)
        label.text = "No Images Available For This Location"
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 2
        return label
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("Dismiss", for: UIControl.State.normal)
        button.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        button.backgroundColor = UIColor.clear
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.addSubview(self.label)
        self.label.anchor(leftTo: self.leftAnchor,
                          rightTo: self.rightAnchor,
                          centerXTo: self.centerXAnchor,
                          centerYTo: self.centerYAnchor)
        
        self.addSubview(self.dismissButton)
        self.dismissButton.anchor(height: 50,
                                  topTo: self.label.bottomAnchor,
                                  leftTo: self.leftAnchor,
                                  rightTo: self.rightAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
