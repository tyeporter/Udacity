//
//  GETPhotoSearchResponseCodable.swift
//  VirtualTourist
//
//  Created by Tye Porter on 5/31/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import Foundation

struct GETPhotoSearchResponseCodable: Codable {
    
    let photos: PhotosCodable
    let stat: String
    
}
