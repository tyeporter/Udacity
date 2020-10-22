//
//  StudentLocationsResponseCodable.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/11/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import Foundation

struct GetStudentLocationsResponseCodable: Codable {
    
    let results: [StudentLocationCodable]
    
}
