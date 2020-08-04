//
//  citities.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/22/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import Foundation
struct Cities {
    let predictions: [CityName]
}
struct CityName {
    let description: String
    let structured_formatting: [Formatting]
}
struct Formatting {
    let main_text: String
}
