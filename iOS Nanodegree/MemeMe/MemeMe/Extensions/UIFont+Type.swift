//
//  UIFont+Type.swift
//  MemeMe
//
//  Created by Tye Porter on 4/8/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    enum FontCondition {
        case isBlack, isHeavy, isBold, isRegular
    }
    
    func passesFontConditionTest(with fontCondition: FontCondition) -> Bool {
        switch fontCondition {
        case FontCondition.isBlack:
            return (self.contains("Black") && !self.contains("Italic") && !self.contains("Oblique"))
        case FontCondition.isHeavy:
            return (self.contains("Heavy") && !self.contains("Italic") && !self.contains("Oblique"))
        case FontCondition.isBold:
            return (self.contains("Bold") && !self.contains("Semi") && !self.contains("Italic") && !self.contains("Oblique"))
        case FontCondition.isRegular:
            return (!self.contains("Black") && !self.contains("Bold") && !self.contains("Italic") && !self.contains("Oblique") && !self.contains("Light") && !self.contains("light") && !self.contains("Thin") && !self.contains("Medium") && !self.contains("Semibold"))
        }
    }
    
}
