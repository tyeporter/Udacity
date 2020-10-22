//
//  UIColor+RGB.swift
//  MemeMe
//
//  Created by Tye Porter on 4/8/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}
