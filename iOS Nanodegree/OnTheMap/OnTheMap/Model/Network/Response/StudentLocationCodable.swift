//
//  StudentLocationCodable.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/11/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import Foundation

struct StudentLocationCodable: Codable, Equatable {
    
    let firstName: String
    let lastName: String
    let longitude: Double
    let latitude: Double
    let mapString: String
    let mediaURL: String
    let uniqueKey: String
    let objectId: String
    let createdAt: String
    let updatedAt: String
    
}
