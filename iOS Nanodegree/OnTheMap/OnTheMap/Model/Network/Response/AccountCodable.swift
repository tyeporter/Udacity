//
//  AccountCodable.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/11/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import Foundation

struct AccountCodable: Codable {
    
    let isRegistered: Bool
    let key: String
    
    enum CodingKeys: String, CodingKey {
        case isRegistered = "registered"
        case key
    }
    
}
