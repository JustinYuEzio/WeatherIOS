//
//  weatherDisplay.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/22/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import Foundation
struct WeatherDisplay: Codable {
    let summary: String
    let temperature: Double
    let humidity: Double
    let windSpeed: Double
    let visibility: Double
    let pressure: Double
    let icon: String
    let daily: Daily
    let prec: Double
    let ozone: Double
    let cc: Double
}
