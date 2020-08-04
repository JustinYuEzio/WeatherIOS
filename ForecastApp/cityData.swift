//
//  cityData.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/22/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import Foundation
struct CityData: Codable {
    let predictions: [CityPre]
}
struct CityPre: Codable {
    let description: String
    let structured_formatting: Format
}
struct Format: Codable {
    let main_text: String
}
