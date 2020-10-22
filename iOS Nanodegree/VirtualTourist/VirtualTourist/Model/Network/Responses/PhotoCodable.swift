//
//  PhotoCodable.swift
//  VirtualTourist
//
//  Created by Tye Porter on 5/31/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import Foundation

public class PhotoCodable: NSObject, Codable {
    
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    
}
