//
//  UIView+Anchor.swift
//  Created by Tye Porter on 3/16/19.
//  Copyright © 2019 Tye Porter. All rights reserved.
//

import UIKit

extension UIView {
    
    func anchor(width: CGFloat = 0, height: CGFloat = 0, topTo: NSLayoutYAxisAnchor? = nil, bottomTo: NSLayoutYAxisAnchor? = nil, leftTo: NSLayoutXAxisAnchor? = nil, rightTo: NSLayoutXAxisAnchor? = nil, padTop: CGFloat = 0, padBottom: CGFloat = 0, padLeft: CGFloat = 0, padRight: CGFloat = 0, centerXTo: NSLayoutXAxisAnchor? = nil, centerYTo: NSLayoutYAxisAnchor? = nil, offsetXBy: CGFloat = 0, offsetYBy: CGFloat = 0){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        if let topTo = topTo {
            self.topAnchor.constraint(equalTo: topTo, constant: padTop).isActive = true
        }
        
        if let bottomTo = bottomTo {
            self.bottomAnchor.constraint(equalTo: bottomTo, constant: -padBottom).isActive = true
        }
        
        if let leftTo = leftTo {
            self.leftAnchor.constraint(equalTo: leftTo, constant: padLeft).isActive = true
        }
        
        if let rightTo = rightTo {
            self.rightAnchor.constraint(equalTo: rightTo, constant: -padRight).isActive = true
        }
        
        if let centerXTo = centerXTo {
            self.centerXAnchor.constraint(equalTo: centerXTo, constant: offsetXBy).isActive = true
        }
        
        if let centerYTo = centerYTo {
            self.centerYAnchor.constraint(equalTo: centerYTo, constant: offsetYBy).isActive = true
        }
    }
    
    func removeConstraintsFromAllEdges(){
        if let superview = self.superview {
            for constraint in superview.constraints {
                if let firstItem = constraint.firstItem, firstItem === self {
                    superview.removeConstraint(constraint)
                }

                if let secondItem = constraint.secondItem, secondItem === self {
                    superview.removeConstraint(constraint)
                }
            }
        }
    }
    
}
