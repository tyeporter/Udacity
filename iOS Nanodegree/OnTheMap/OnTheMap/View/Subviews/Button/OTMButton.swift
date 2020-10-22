//
//  LoginButotn.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/11/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

class OTMButton: UIButton {
    
    // MARK: Properties
    var buttonColor: UIColor?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.otmAshyBlack
        self.layer.cornerRadius = 4
        self.setTitleColor(UIColor.red, for: UIControl.State.selected)
        self.titleLabel?.font = UIFont(name: "MavenPro-Bold", size: 16)!
        self.setTitleColor(UIColor.white, for: UIControl.State.normal)
    }
    
    // MARK: - Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.backgroundColor = UIColor.udacityBlue
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.backgroundColor = self.buttonColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
