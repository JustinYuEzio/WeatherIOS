//
//  ViewController.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/22/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import UIKit
import SwiftSpinner
import CoreLocation
import SwiftUI
import Alamofire
import Toast_Swift
class ViewController: UIViewController {
    var locationManager = CLLocationManager()
    var curLat: Double = 0.0
    var curLng: Double = 0.0
    var cities: [CityPre] = Array()
    var weatherData: WeatherDisplay?
    var curSet = false
    var dailyData: [DailyData] = Array()
    var inputCity: String = ""
    var cityNameStr: String = ""
    var lat: Double = -1
    var lng: Double = -1
    var cityTable: UITableView?
    @IBOutlet weak var subviewSum: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var subviewTemp: UILabel!
    @IBOutlet weak var subviewCity: UILabel!
    @IBOutlet weak var subViewImage: UIImageView!
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var dailyTable: UITableView!

    let favData = UserDefaults.standard
    @IBOutlet weak var humi: UILabel!
    @IBOutlet weak var ws: UILabel!
    @IBOutlet weak var visi: UILabel!
    @IBOutlet weak var pres: UILabel!
    let searchBar = UISearchBar()
    var httpRequest = HttpRequest()
    var tableDrawed: [Int] = Array()
    var subViewDrawed: [Int] = Array()
    var goToResult = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityTable = createCityView()
        cityTable?.isHidden = true
        view.addSubview(cityTable!)
        scrollView.delegate = self
        favData.set(0, forKey: "favCityNum")
        subView.layer.borderWidth = 2
        subView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        subView.layer.cornerRadius = 10
        dailyTable.layer.borderWidth = 2
        dailyTable.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        dailyTable.layer.cornerRadius = 10
        dailyTable.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        navBarItem.titleView = searchBar
        dailyTable.delegate = self
        dailyTable.dataSource = self
        dailyTable.isHidden = true
        httpRequest.delegate = self
        searchBar.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        if favData.value(forKey: "favList") as? [String] == nil {
            favData.set([""], forKey: "favList")
        }
//        locationManager.delegate = self
//        locationManager.requestAlwaysAuthorization()
//        locationManager.requestLocation()
        searchBar.text = ""
    }
    override func viewDidAppear(_ animated: Bool) {
        let favList = favData.value(forKey: "favList") as! [String]
        print(favList)
        addFavCity()
        inputCity = cityNameStr
        httpRequest.getCurrentLocation()
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func addFavCity() {
        let favList = favData.value(forKey: "favList") as! [String]
        let num = favList.count
        if favList.count == 0 {
            pageControl.numberOfPages = 0
        }
        for _ in 0..<favList.count {
            tableDrawed.append(0)
            subViewDrawed.append(0)
        }
        if num != 0 {
            scrollView.contentSize.width = scrollView.frame.size.width * CGFloat(num + 1)
            pageControl.numberOfPages = num + 1
            addCity(num: num, favList: favList)
        }
    }
    
func setSubView(city: String, summary: String, temp: Double, icon: String) {
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

    @IBAction func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
           if gestureRecognizer.state == .ended {
            searchBar.endEditing(true)
           }
       }
    func getCurrCityName(location: CLLocation) {
        SwiftSpinner.show("Loading")
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)  in
            if let city = placemarks{
                self.cityNameStr = city[0].locality!
            }
        })

    }
    func setStackView(humi: Double, ws: Double, visi: Double, pres: Double) {
        self.humi.text = String(format:"%.1f", humi * 100) + "%"
        self.ws.text = String(format:"%.2f", ws) + " mph"
        self.visi.text = String(format:"%.2f", visi) + " km"
        self.pres.text = String(format:"%.2f", pres) + " mb"
    }
    func getData(cityName: String) -> WeatherDisplay? {
        if let weatherData = favData.data(forKey: cityName),
            let data = try? JSONDecoder().decode(WeatherDisplay.self, from: weatherData) {
            return data
        } else {
            return nil
        }
    }
    
    @objc func myviewTapped(_ recognizer: UIGestureRecognizer) {
        performSegue(withIdentifier: "showFav", sender: self)
    }
    func createFavSubView1(num: Int, data: WeatherDisplay) -> UIView {
        let subView = UIView()
        subView.layer.borderWidth = 1
        subView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        subView.layer.cornerRadius = 10
        subView.frame = CGRect(x: 30 , y: 48, width: 315, height: 177)
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 20, y: 28, width: 99, height: 108)
        let icon = data.icon
        switch icon {
            case "cloudy":
                imageView.image = #imageLiteral(resourceName: "weather-cloudy")
            case "clear-day":
                imageView.image = #imageLiteral(resourceName: "weather-sunny")
            case "clear-night":
                imageView.image = #imageLiteral(resourceName: "weather-night")
            case "rain":
                imageView.image = #imageLiteral(resourceName: "weather-rainy")
            case "snow":
                imageView.image = #imageLiteral(resourceName: "weather-snowy")
            case "sleet":
                imageView.image = #imageLiteral(resourceName: "weather-snowy-rainy")
            case "wind":
                imageView.image = #imageLiteral(resourceName: "weather-windy-variant")
            case "fog":
                imageView.image = #imageLiteral(resourceName: "weather-fog")
            case "partly-cloudy-day":
                imageView.image = #imageLiteral(resourceName: "weather-partly-cloudy")
            case "partly-cloudy-night":
                imageView.image = #imageLiteral(resourceName: "weather-partly-cloudy")
            default:
                imageView.image = #imageLiteral(resourceName: "weather-partly-cloudy")
        }
        let favList = favData.value(forKey: "favList") as! [String]
        let city = UILabel()
        city.frame = CGRect(x: 142, y: 18, width: 173, height: 42)
        var cityDisplay = favList[num]
        if let index = cityDisplay.firstIndex(of: ",") {
            cityDisplay = String(cityDisplay.prefix(upTo: index))
        }
        city.text = cityDisplay
        city.font = city.font.withSize(22)
        let sum = UILabel()
        sum.text = data.summary
        sum.font = sum.font.withSize(17)
        sum.frame = CGRect(x: 142, y: 59, width: 173, height: 42)
        let temp = UILabel()
        temp.font = temp.font.withSize(27)
        temp.text = String(format:"%.0f", data.temperature) + "℉"
        temp.frame = CGRect(x: 142, y: 104, width: 173, height: 42)
        subView.addSubview(city)
        subView.addSubview(sum)
        subView.addSubview(temp)
        subView.addSubview(imageView)
        addTap(subView: subView)
        subView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2946275684)
        return subView
    }
    func addTap(subView: UIView) {
        var tapGesture = UITapGestureRecognizer()
           tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.myviewTapped(_:)))
           subView.isUserInteractionEnabled = true
           subView.addGestureRecognizer(tapGesture)
    }
    func createFavSubView2(num: Int, data: WeatherDisplay) -> UIStackView {
        let subView = UIStackView()
        subView.distribution = .fillEqually
        subView.alignment = .center
        let stack1 = UIStackView()
        stack1.frame = CGRect(x: 0, y: 0, width: 93, height: 117)
        let humiText = UILabel()
        humiText.frame = CGRect(x: 12.5, y: 0, width: 68.5, height: 20.5)
        humiText.text = "Humidity"
        let humi = UILabel()
        humi.frame = CGRect(x: 24, y: 96.5, width: 70, height: 20.5)
        humi.text = String(format:"%.1f", data.humidity * 100) + "%"
        let icon1 = UIImageView()
        icon1.frame = CGRect(x: 21.5, y: 33.5, width: 50, height: 50)
        icon1.image = #imageLiteral(resourceName: "water-percent50")
        stack1.addSubview(icon1)
        stack1.addSubview(humiText)
        stack1.addSubview(humi)
        let stack2 = UIStackView()
         stack2.frame = CGRect(x: 90, y: 0, width: 93, height: 117)
        let wsText = UILabel()
        wsText.frame = CGRect(x: 0, y: 0, width: 93, height: 20.5)
        wsText.text = "Wind Speed"
        let ws = UILabel()
        ws.frame = CGRect(x: 7.5, y: 96.5, width: 78, height: 20.5)
        ws.text = String(format:"%.2f", data.windSpeed) + " mph"
        let icon2 = UIImageView()
        icon2.frame = CGRect(x: 21.5, y: 33.5, width: 50, height: 50)
        icon2.image = #imageLiteral(resourceName: "weather-windy50")
        stack2.addSubview(icon2)
        stack2.addSubview(wsText)
        stack2.addSubview(ws)
        let stack3 = UIStackView()
         stack3.frame = CGRect(x: 90 * 2, y: 0, width: 93, height: 117)
        let visiText = UILabel()
        visiText.frame = CGRect(x: 12.5, y: 0, width: 68.5, height: 20.5)
        visiText.text = "Visibility"
        let visi = UILabel()
        visi.frame = CGRect(x: 7.5, y: 96.5, width: 78, height: 20.5)
        visi.text = String(format:"%.2f", data.visibility) + " km"
        let icon3 = UIImageView()
        icon3.frame = CGRect(x: 21.5, y: 33.5, width: 50, height: 50)
        icon3.image = #imageLiteral(resourceName: "eye-outline")
        stack3.addSubview(icon3)
        stack3.addSubview(visiText)
        stack3.addSubview(visi)
        let stack4 = UIStackView()
        let presText = UILabel()
        presText.frame = CGRect(x: 12.5, y: 0, width: 68.5, height: 20.5)
        presText.text = "Pressure"
        let pres = UILabel()
        pres.frame = CGRect(x: 7.5, y: 96.5, width: 120, height: 20.5)
        pres.text = String(format:"%.2f", data.pressure) + " mb"
        let icon4 = UIImageView()
        icon4.frame = CGRect(x: 21.5, y: 33.5, width: 50, height: 50)
        icon4.image = #imageLiteral(resourceName: "gauge50")
        stack4.addSubview(icon4)
        stack4.addSubview(presText)
        stack4.addSubview(pres)
        stack4.frame = CGRect(x: 90 * 3, y: 0, width: 93, height: 117)
        subView.frame = CGRect(x: 6, y: 259, width: 363, height: 117)
        subView.addSubview(stack1)
        subView.addSubview(stack2)
        subView.addSubview(stack3)
        subView.addSubview(stack4)
        subView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2276862158)
        return subView
    }
    func addButton() -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: 330, y: 10, width: 50, height: 40)
        button.setImage(#imageLiteral(resourceName: "trash-can"), for: .normal)
        return button
    }
    @objc func deleteFav(sender: UIButton!) {
        
        var num = pageControl.currentPage
        if num == 1 {
            pageControl.numberOfPages = 0
        }
        var favList = favData.value(forKey: "favList") as! [String]
        let cityName = favList[num - 1]
        var newFavList: [String] = Array()
        for i in 0..<favList.count {
            if favList[i] != cityName {
                newFavList.append(favList[i])
            }
        }
        self.view.makeToast(cityName + " was removed from the Favourate List")
        favData.removeObject(forKey: cityName)
        for i in 0..<tableDrawed.count {
            tableDrawed[i] = 0
            subViewDrawed[i] = 0
        }
        favData.set(newFavList, forKey:"favList")
        favList = favData.value(forKey: "favList") as! [String]
        num = favList.count
        var count = 0
        for view in scrollView.subviews{
            if count < 1 {
                count += 1
                continue
            }
            view.removeFromSuperview()
        }
        scrollView.contentSize.width = scrollView.frame.size.width * CGFloat(num + 1)
        pageControl.numberOfPages = num + 1
        addCity(num: num, favList: favList)
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    func createCityView() -> UITableView {
        let tableView = UITableView()
        tableView.frame = CGRect(x: 7, y: 55, width: 361, height: 251)
        tableView.layer.cornerRadius = 10
        tableView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        tableView.layer.borderWidth = 1
        tableView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.82)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.register(CityTableViewCell.self, forCellReuseIdentifier: "city")
        return tableView
    }
    func createTableView(num: Int, data: WeatherDisplay) -> UITableView {
        let tableView = UITableView()
        let width = self.view.frame.size.width
        tableView.frame = CGRect(x: 7 + CGFloat(num) * width, y: 418, width: 361, height: 250)
        tableView.layer.cornerRadius = 10
        tableView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        tableView.layer.borderWidth = 1
        tableView.backgroundColor = #colorLiteral(red: 0.9058110118, green: 0.8745594621, blue: 0.8940114379, alpha: 0.1431399829)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.allowsSelection = false
        tableView.register(FavTableViewCell.self, forCellReuseIdentifier: "FavTableViewCell")
        return tableView
    }
    func addCity(num: Int, favList:[String]) {
        for i in 0..<num {
            if subViewDrawed[i] == 0 {
                subViewDrawed[i] = 1
                let newView = UIView()
                let x = self.view.frame.size.width
                newView.frame = CGRect(x: x * CGFloat(i + 1), y: 0, width: self.view.frame.width, height: self.view.frame.height)
                if favList[i] == "" {
                    continue
                }
                let weatherData = getData(cityName: favList[i])!
                let subView1 = createFavSubView1(num: i, data: weatherData)
                newView.addSubview(subView1)
                let subView2 = createFavSubView2(num: i, data: weatherData)
                newView.addSubview(subView2)
                let button = addButton()
                button.addTarget(self, action: #selector(deleteFav), for: .touchUpInside)

                newView.addSubview(button)
                scrollView.addSubview(newView)
            }
        }
        
    }
    
}
//MARK:- UIScroll
extension ViewController: UIScrollViewDelegate {
    func registerCell(tableView: UITableView) {
        let cell = UINib(nibName: "FavTableViewCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "FavTableViewCell")
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        cityTable?.isHidden = true
        let favList = favData.value(forKey: "favList") as! [String]
        let width = self.view.frame.width
        var num = scrollView.contentOffset.x / width
        
        if num == 0 && pageControl.currentPage != 0 {
            num = CGFloat(pageControl.currentPage)
        }
        if favList.count == 0 {
            return
        }
        pageControl.currentPage = Int(num)
        if num >= 1 && tableDrawed[Int(num) - 1] == 0 {
            let weatherData = getData(cityName: favList[Int(num) - 1])!
            let tableView = createTableView(num: Int(num), data: weatherData)
            registerCell(tableView: tableView)
            if tableDrawed[Int(num) - 1] == 0 {
                tableDrawed[Int(num) - 1] = 1
                scrollView.addSubview(tableView)
            }

        }
       }
}
//MARK:- UISearchBar
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if searchText != "" {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            httpRequest.getCity(cityName: searchText)
            cityTable?.isHidden = false
            cityTable?.reloadData()
            
        } else {
            cityTable?.isHidden = true
        }
    }
}

//MARK: - CLLocation

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        curLat = locValue.latitude
        curLng = locValue.longitude
        getCurrCityName(location: manager.location!)
        httpRequest.getWeather(lat: curLat, lng: curLng)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - HttpRequest
extension ViewController: HttpRequestDelegate {
    func didGetCity(cityData: CityData) {
        cities = cityData.predictions
    }
    func didUpdateWeather(weather: WeatherDisplay) {
        weatherData = weather
        dailyData = weather.daily.data
        if !curSet {
            curSet = true
            dailyTable.reloadData()
            dailyTable.isHidden = false
            setSubView(city: cityNameStr, summary: weather.summary, temp: weather.temperature, icon: weather.icon)
            setStackView(humi: weather.humidity, ws: weather.windSpeed, visi: weather.visibility, pres: weather.pressure)
        }
        if goToResult {
            goToResult = false
            self.performSegue(withIdentifier: "showResult", sender: self)
        }
    }
    func didGetLocation(location: Location) {
        lat = location.lat
        lng = location.lng
        print(lat)
        print("-----------------")
        print(lng)
        httpRequest.getWeather(lat: lat, lng: lng)
    }
    func didGetCurrent(current: CurrentData) {
        curLat = current.lat
        curLng = current.lon
        cityNameStr = current.city
        httpRequest.getWeather(lat: curLat, lng: curLng)
    }
}
//MARK:- UITableView
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case cityTable:
            return cities.count
        case dailyTable:
            return dailyData.count
        default:
            return 8
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case cityTable:
            let cell = tableView.dequeueReusableCell(withIdentifier:"city", for: indexPath)
            cell.textLabel?.text = cities[indexPath.row].description
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            return cell
        case dailyTable:
            let cell = tableView.dequeueReusableCell(withIdentifier:"sunrise", for: indexPath) as! DailyCustomCell
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"

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
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier:"FavTableViewCell", for: indexPath) as! FavTableViewCell
            let num = pageControl.currentPage
            let favList = favData.value(forKey: "favList") as! [String]
            let weather = getData(cityName: favList[num - 1])!
            let dailyData = weather.daily.data
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
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cityTable {
            cityTable?.isHidden = true
            inputCity = (cityTable?.cellForRow(at: indexPath)?.textLabel!.text)!
            searchBar.text = inputCity
            cityTable?.deselectRow(at: indexPath, animated: true)
            httpRequest.getLocation(description: inputCity)
            searchBar.endEditing(true)
            goToResult = true
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ResultController {
            let result = segue.destination as! ResultController
            result.dailyData = dailyData
            result.weatherData = weatherData
            result.city = inputCity
        }
        if segue.destination is FavViewController {
            let fav = segue.destination as! FavViewController
            let favList = favData.value(forKey: "favList") as! [String]
            let index = pageControl.currentPage - 1
            let cityName = favList[index]
            fav.cityName = cityName
            fav.weatherData = getData(cityName: cityName)
            for vc in fav.viewControllers! {
                if vc is TodayViewController {
                    let today = vc as! TodayViewController
                    today.weatherData = fav.weatherData
                    today.cityName = fav.cityName
                }
                if vc is WeekViewController {
                    let week = vc as! WeekViewController
                    week.weatherData = fav.weatherData
                    week.cityName = fav.cityName
                }
                if vc is PhotoViewController {
                    let photo = vc as! PhotoViewController
                    photo.cityName = fav.cityName
                }
            }
        }
        if segue.destination is DetailViewController {
            let detail = segue.destination as! DetailViewController
                detail.weatherData = weatherData
            if inputCity == "" {
                detail.cityName = cityNameStr
            } else {
                detail.cityName = inputCity
            }
            for vc in detail.viewControllers! {
                if vc is TodayViewController {
                    let today = vc as! TodayViewController
                    today.weatherData = detail.weatherData
                    today.cityName = detail.cityName
                }
                if vc is WeekViewController {
                    let week = vc as! WeekViewController
                    week.weatherData = detail.weatherData
                    week.cityName = detail.cityName
                }
                if vc is PhotoViewController {
                    let photo = vc as! PhotoViewController
                    photo.cityName = detail.cityName
                }
            }
        }
    }
}
