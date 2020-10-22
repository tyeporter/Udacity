//
//  PhotosCodable.swift
//  VirtualTourist
//
//  Created by Tye Porter on 5/31/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import Foundation

struct PhotosCodable: Codable {
    
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [PhotoCodable]
    
}
