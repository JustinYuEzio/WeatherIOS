//
//  TodayViewController.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/23/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {
    var weatherData: WeatherDisplay!
    var cityName: String = ""
    @IBOutlet var collection:[UIView]!
    @IBOutlet weak var ws: UILabel!
    @IBOutlet weak var pres: UILabel!
    @IBOutlet weak var prec: UILabel!
   
    @IBOutlet weak var ozone: UILabel!
    @IBOutlet weak var cc: UILabel!
    @IBOutlet weak var visi: UILabel!
    @IBOutlet weak var sum: UILabel!
    let defaults = UserDefaults.standard
    @IBOutlet weak var humi: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temp: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        for view in collection {
            view.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 10
        }
        let iconData = weatherData.icon
        switch iconData {
            case "cloudy":
                icon.image = #imageLiteral(resourceName: "weather-cloudy")
            case "clear-day":
                icon.image = #imageLiteral(resourceName: "weather-sunny")
            case "clear-night":
                icon.image = #imageLiteral(resourceName: "weather-night")
            case "rain":
                icon.image = #imageLiteral(resourceName: "weather-rainy")
            case "snow":
                icon.image = #imageLiteral(resourceName: "weather-snowy")
            case "sleet":
                icon.image = #imageLiteral(resourceName: "weather-snowy-rainy")
            case "wind":
                icon.image = #imageLiteral(resourceName: "weather-windy-variant")
            case "fog":
                icon.image = #imageLiteral(resourceName: "weather-fog")
            case "partly-cloudy-day":
                icon.image = #imageLiteral(resourceName: "weather-partly-cloudy")
            case "partly-cloudy-night":
                icon.image = #imageLiteral(resourceName: "weather-partly-cloudy")
            default:
                icon.image = #imageLiteral(resourceName: "weather-partly-cloudy")
        }
        ws.text = String(format: "%.2f", weatherData.windSpeed) + " mph"
        pres.text = String(format: "%.1f", weatherData.pressure) + " mb"
        prec.text = String(format: "%.1f", weatherData.prec) + " mmph"
        temp.text = String(format: "%.0f", weatherData!.temperature) + "℉"
        sum.text = weatherData!.summary
        humi.text = String(format: "%.1f", weatherData!.humidity * 100) + " %"
        visi.text = String(format: "%.2f", weatherData!.visibility) + " km"
        cc.text = String(format: "%.2f", weatherData!.cc * 100) + " %"
        ozone.text = String(format: "%.2f", weatherData!.ozone) + " DU"
        
    }
}
