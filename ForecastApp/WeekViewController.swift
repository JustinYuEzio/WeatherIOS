//
//  WeekViewController.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/23/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import UIKit
import Charts
class WeekViewController: UIViewController {
    var weatherData: WeatherDisplay?
    var cityName: String = ""
    @IBOutlet weak var sum: UILabel!
    @IBOutlet weak var subViewImage: UIImageView!
    @IBOutlet weak var subView2: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var chartView: LineChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        subView.layer.borderWidth = 1
        subView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        subView.layer.cornerRadius = 10
        subView2.layer.borderWidth = 1
        subView2.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        subView2.layer.cornerRadius = 10
        sum.text = weatherData!.daily.summary
        sum.lineBreakMode = NSLineBreakMode.byWordWrapping
        sum.numberOfLines = 0
        switch weatherData?.daily.icon {
        case "cloudy":
            subViewImage.image = #imageLiteral(resourceName: "weather-cloudy")
        case "clear-day":
            subViewImage.image = #imageLiteral(resourceName: "weather-sunny")
        case "clear-night":
            subViewImage.image = #imageLiteral(resourceName: "weather-night")
        case "rain":
            subViewImage.image = #imageLiteral(resourceName: "weather-rainy")
        case "snow":
            subViewImage.image = #imageLiteral(resourceName: "weather-snowy")
        case "sleet":
            subViewImage.image = #imageLiteral(resourceName: "weather-snowy-rainy")
        case "wind":
            subViewImage.image = #imageLiteral(resourceName: "weather-windy-variant")
        case "fog":
            subViewImage.image = #imageLiteral(resourceName: "weather-fog")
        case "partly-cloudy-day":
            subViewImage.image = #imageLiteral(resourceName: "weather-partly-cloudy")
        case "partly-cloudy-night":
            subViewImage.image = #imageLiteral(resourceName: "weather-partly-cloudy")
        default:
            subViewImage.image = #imageLiteral(resourceName: "weather-partly-cloudy")
        }
        
               
        setChart()
        chartView.noDataText = "no data"
        // Do any additional setup after loading the view.
    }
    func setChart() {
        var tempMin = [Double]()
        var tempMax = [Double]()
        let data = weatherData!.daily.data
        for i in 0..<data.count {
            tempMin.append(data[i].temperatureMin)
            tempMax.append(data[i].temperatureMax)
        }
        var tempMinEntry = [ChartDataEntry]()
        var tempMaxEntry = [ChartDataEntry]()
        var white: NSUIColor
        var orange: NSUIColor
        orange = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        white = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        for i in 0..<8 {
            let minValue = ChartDataEntry(x: Double(i),y:tempMin[i])
            let maxValue = ChartDataEntry(x: Double(i),y:tempMax[i])
            tempMinEntry.append(minValue)
            tempMaxEntry.append(maxValue)
        }
        
        let dataMin = LineChartDataSet(entries: tempMinEntry, label: "Minimum Temperature (℉)")
        dataMin.circleRadius = 4
        //dataMin.circleHoleColor = testColor
    
        dataMin.setColor(white)
        dataMin.setCircleColor(white)
        let dataMax = LineChartDataSet(entries: tempMaxEntry, label: "Maximum Temperature (℉)")
        dataMax.circleRadius = 4
        dataMax.setCircleColor(orange)
        dataMax.setColor(orange)
        let temp = LineChartData()
            temp.addDataSet(dataMin)
        temp.addDataSet(dataMax)
            chartView.data = temp
    }
     
}
