//
//  detailViewController.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/22/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import UIKit
class DetailViewController: UITabBarController {
    var cityName = ""
    var weatherData: WeatherDisplay?
    @IBOutlet weak var navBar: UINavigationItem!
    override func viewDidLoad() {
        if let index = cityName.firstIndex(of: ",") {
            let city = String(cityName.prefix(upTo: index))
            navBar.title = city
        } else {
            navBar.title = cityName
        }
        
        super.viewDidLoad()
    }
    @IBAction func twitter(_ sender: UIBarButtonItem) {
        var url = URLComponents(string: "https://twitter.com/intent/tweet")
        var weatherInfo = ""
        if let index = cityName.firstIndex(of: ",") {
            let city = String(cityName.prefix(upTo: index))
            weatherInfo = "The current temperature at " + city + " is "
        } else {
             weatherInfo = "The current temperature at " + cityName + " is "
        }
        let temp = String(format: "%.0f",weatherData!.temperature)
        
        weatherInfo = weatherInfo + temp + "℉. The weather conditions are " + weatherData!.summary + ".\n" + "#CSCI571WeatherSearch"
        let query = URLQueryItem(name: "text", value: weatherInfo)
        url?.queryItems = [query]
        if UIApplication.shared.canOpenURL(url!.url!) {
            UIApplication.shared.open(url!.url!, options: [:], completionHandler: nil)
        }
    }
}
