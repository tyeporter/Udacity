//
//  ClearPinsButton.swift
//  VirtualTourist
//
//  Created by Tye Porter on 6/3/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

class ClearPinsButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.tintColor = UIColor.white
        self.setImage(UIImage(named: "clear_pins"), for: UIControl.State.normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
