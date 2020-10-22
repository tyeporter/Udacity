//
//  Collection+Extensions.swift
//  VirtualTourist
//
//  Created by Tye Porter on 5/28/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import Foundation
import CoreData

extension Collection {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.creationDate = Date()
    }
    
}
