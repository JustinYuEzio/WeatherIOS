//
//  imageData.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/24/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import Foundation
struct ImageData: Codable {
    let items:[Item]
}
struct Item: Codable {
    let pagemap: Page_Map
    let kind: String
}
struct Page_Map: Codable {
    let cse_image: [Cse_Image]
}
struct Cse_Image: Codable {
}
