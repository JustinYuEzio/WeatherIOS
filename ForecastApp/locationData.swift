//
//  locationData.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/22/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import Foundation
struct LocationData:Codable {
    let results: [LocData]
}
struct LocData:Codable {
    let geometry:Geometry
}
struct Geometry: Codable {
    let location: Location
}
struct Location:Codable {
    let lat: Double
    let lng: Double
}
