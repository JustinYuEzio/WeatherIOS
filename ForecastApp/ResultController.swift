//
//  ResultController.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/22/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import UIKit
import Toast_Swift
class ResultController: UIViewController {

    @IBOutlet weak var subView: UIView!
    var weatherData: WeatherDisplay?
    var dailyData: [DailyData] = Array()
    var city: String = ""
    var testcity: [CityPre] = Array()
    @IBOutlet weak var navBar: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var pres: UILabel!
    @IBOutlet weak var visi: UILabel!
    @IBOutlet weak var ws: UILabel!
    @IBOutlet weak var humi: UILabel!
    @IBOutlet weak var subViewImage: UIImageView!
    @IBOutlet weak var subviewSum: UILabel!
    @IBOutlet weak var subviewTemp: UILabel!
    @IBOutlet weak var subviewCity: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var favButton: UIButton!
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        subView.layer.borderWidth = 1
        subView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        subView.layer.cornerRadius = 10
        tableView.layer.cornerRadius = 10
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        if let index = city.firstIndex(of: ",") {
            tableView.reloadData()
            let cityName = String(city.prefix(upTo: index))
            navBar.title = cityName
            navigationItem.title = cityName
             setSubView(city: cityName, summary: weatherData!.summary, temp: weatherData!.temperature, icon: weatherData!.icon)
            setStackView(humi: weatherData!.humidity, ws: weatherData!.windSpeed, visi: weatherData!.visibility, pres: weatherData!.pressure)
        }
       
        super.viewDidLoad()
    }
   
    override func viewDidAppear(_ animated: Bool) {
        if isInFavList(cityName: city) {
            favButton.setImage(#imageLiteral(resourceName: "trash-can"), for: .normal)
        } else {
            favButton.setImage(#imageLiteral(resourceName: "plus-circle"), for: .normal)
        }
    }
    @IBAction func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
           if gestureRecognizer.state == .ended {
               
           }
       }
    func setSubView(city: String, summary: String, temp: Double, icon: String) {
        print(icon)
        switch icon {
            
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
        subviewSum.text = summary
        subviewTemp.text = String(format: "%.0f", temp) + "℉"
        subviewCity.text = city
    }
    func setStackView(humi: Double, ws: Double, visi: Double, pres: Double) {
        self.humi.text = String(format:"%.1f", humi * 100) + "%"
        self.ws.text = String(format:"%.2f", ws) + " mph"
        self.visi.text = String(format:"%.2f", visi) + " km"
        self.pres.text = String(format:"%.2f", pres) + " mb"
    }

    @IBAction func twitter(_ sender: UIBarButtonItem) {
        var url = URLComponents(string: "https://twitter.com/intent/tweet")
        let index = city.firstIndex(of: ",")!
        let cityName = String(city.prefix(upTo: index))
        let temp = String(format: "%.0f",weatherData!.temperature)
        let weatherInfo = "The current temperature at " + cityName + " is " + temp + "℉. The weather conditions are " + weatherData!.summary + ".\n" + "#CSCI571WeatherSearch"
        let query = URLQueryItem(name: "text", value: weatherInfo)
        url?.queryItems = [query]
        if UIApplication.shared.canOpenURL(url!.url!) {
            UIApplication.shared.open(url!.url!, options: [:], completionHandler: nil)
        }
    }
    func isInFavList(cityName: String) -> Bool{
        let favData = UserDefaults.standard
        if let favList = favData.value(forKey: "favList") {
            let favList = favData.value(forKey: "favList") as! [String]
            for i in 0..<favList.count {
                if favList[i] == cityName {
                    return true
                }
            }
        }
        return false
    }
    @IBAction func favAction(_ sender: UIButton) {
        if isInFavList(cityName: city) {
            favButton.setImage(#imageLiteral(resourceName: "plus-circle"), for: .normal)
            self.view.makeToast(city + " was removed from the Favourate List")
            let favList = defaults.value(forKey: "favList") as! [String]
            var newFavList: [String] = Array()
            for i in 0..<favList.count {
                if favList[i] != city && favList[i] != "" {
                    newFavList.append(favList[i])
                }
            }
            defaults.removeObject(forKey: city)
            defaults.set(newFavList, forKey:"favList")
            print(newFavList)
        } else {
            favButton.setImage(#imageLiteral(resourceName: "trash-can"), for: .normal)
            self.view.makeToast(city + " was added to the Favourate List")
            if let weatherData = try? JSONEncoder().encode(weatherData) {
                if defaults.value(forKey: "favList") != nil {
                    var favList = defaults.value(forKey: "favList") as! [String]
                    if favList.count == 0 {
                        favList.append(city)
                    }
                    if favList[0] == "" {
                        favList[0] = city;
                    } else {
                        favList.append(city)
                    }
                    defaults.set(favList, forKey: "favList")
                    defaults.set(weatherData, forKey: city)
                }
            }
        }
    }
}
//MARK:- tableView
extension ResultController: UITableViewDataSource, UITableViewDelegate {
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return dailyData.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"sunrise", for: indexPath) as! DailyCustomCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        let date = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(dailyData[indexPath.row].time)))
        dateFormatter.dateFormat = "HH:MM"
        let sunrise = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(dailyData[indexPath.row].sunriseTime)))
        let sunset = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(dailyData[indexPath.row].sunsetTime)))
        cell.date.text = date
        cell.sunriseTime.text = sunrise
        cell.sunsetTime.text = sunset
        let icon = dailyData[indexPath.row].icon
        switch icon {
            case "cloudy":
                cell.icon.image = #imageLiteral(resourceName: "weather-cloudy")
            case "clear-day":
                cell.icon.image = #imageLiteral(resourceName: "weather-sunny")
            case "clear-night":
                cell.icon.image = #imageLiteral(resourceName: "weather-night")
            case "rain":
                cell.icon.image = #imageLiteral(resourceName: "weather-rainy")
            case "snow":
                cell.icon.image = #imageLiteral(resourceName: "weather-snowy")
            case "sleet":
                cell.icon.image = #imageLiteral(resourceName: "weather-snowy-rainy")
            case "wind":
                cell.icon.image = #imageLiteral(resourceName: "weather-windy-variant")
            case "fog":
                cell.icon.image = #imageLiteral(resourceName: "weather-fog")
            case "partly-cloudy-day":
                cell.icon.image = #imageLiteral(resourceName: "weather-partly-cloudy")
            case "partly-cloudy-night":
                cell.icon.image = #imageLiteral(resourceName: "weather-partly-cloudy")
            default:
                cell.icon.image = #imageLiteral(resourceName: "weather-partly-cloudy")
        }
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3233625856)
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DetailViewController {
            let detail = segue.destination as! DetailViewController
                detail.cityName = city
                detail.weatherData = weatherData
            for vc in detail.viewControllers! {
                if vc is TodayViewController {
                    let today = vc as! TodayViewController
                    today.weatherData = detail.weatherData
                    today.cityName = detail.cityName
                }
                if vc is WeekViewController {
                    let week = vc as! WeekViewController
                    week.weatherData = weatherData
                    print("set")
                }
                if vc is PhotoViewController {
                    let photo = vc as! PhotoViewController
                    photo.cityName = detail.cityName
                }
            }
            }
        }
}
