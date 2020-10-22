//
//  UIColor+RGB.swift
//  Created by Tye Porter on 4/8/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var udacityBlue = UIColor.rgb(r: 80, g: 177, b: 223)
    static var otmLightGray = UIColor.rgb(r: 48, g: 48, b: 48)
    static var otmMediumGray = UIColor.rgb(r: 38, g: 38, b: 38)
    static var otmDarkGray = UIColor.rgb(r: 32, g: 32, b: 32)
    static var otmAshyBlack = UIColor.rgb(r: 20, g: 20, b: 20)
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
}
