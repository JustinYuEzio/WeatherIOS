//
//  FavViewController.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/26/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import UIKit

class FavViewController: UITabBarController {

    @IBOutlet weak var NavItem: UINavigationItem!
    var cityName = ""
    var currentPage = 0
    let favData = UserDefaults.standard
    var weatherData: WeatherDisplay?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let index = cityName.firstIndex(of: ",") {
            let city = String(cityName.prefix(upTo: index))
            NavItem.title = city
        }
    }

    
    @IBAction func twitter(_ sender: UIBarButtonItem) {
           var url = URLComponents(string: "https://twitter.com/intent/tweet")
           let index = cityName.firstIndex(of: ",")!
           cityName = String(cityName.prefix(upTo: index))
           let temp = String(format: "%.0f",weatherData!.temperature)
           let weatherInfo = "The current temperature at " + cityName + " is " + temp + "℉. The weather conditions are " + weatherData!.summary + ".\n" + "#CSCI571WeatherSearch"
           let query = URLQueryItem(name: "text", value: weatherInfo)
           url?.queryItems = [query]
           if UIApplication.shared.canOpenURL(url!.url!) {
               UIApplication.shared.open(url!.url!, options: [:], completionHandler: nil)
           }
       }

}
