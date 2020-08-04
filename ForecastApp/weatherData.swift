//
//  weatherData.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/22/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import Foundation
struct WeatherData:Codable {
    let timezone: String
    let currently: Current
    let daily: Daily
}
struct Current:Codable {
    let summary: String
    let temperature: Double
    let humidity: Double
    let windSpeed: Double
    let visibility: Double
    let pressure: Double
    let icon: String
    let precipProbability: Double
    let ozone: Double
    let cloudCover: Double
}
struct Daily:Codable {
    let data:[DailyData]
    let summary: String
    let icon: String
}
struct DailyData:Codable {
    let time: Int
    let icon: String
    let sunriseTime: Int
    let sunsetTime: Int
    let temperatureMin: Double
    let temperatureMax: Double
}

