//
//  currentData.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 1/12/20.
//  Copyright © 2020 Hengyi Yu. All rights reserved.
//

import Foundation
struct CurrentData: Codable {
    let lat: Double
    let lon: Double
    let city: String
}

