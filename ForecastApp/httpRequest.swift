//
//  httpRequest.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/22/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftSpinner
protocol HttpRequestDelegate {
    func didUpdateWeather(weather: WeatherDisplay)
    func didGetCity(cityData: CityData)
    func didGetLocation(location: Location)
    func didGetCurrent(current: CurrentData)
}
protocol ImageDelegate {
    func didGetImage(image: ImageData)
}
struct HttpRequest {
    let weatherURL = "http://weathersearch-env.eba-vmsvqibd.us-west-1.elasticbeanstalk.com/weather"
    let autoCompleteURL =
    "http://weathersearch-env.eba-vmsvqibd.us-west-1.elasticbeanstalk.com/auto_complete"
    var imageURL = "https://www.googleapis.com/customsearch/v1?q="
    let imageURLParttwo = "&cx=004574372782316189998:y3pkhtxd46f&imgSize=huge&img_Type=news&search_Type=image&key=AIzaSyBX2yu-OegebXiNeabsw5ohXtpOi9_GhUM"
    let locationURL = "http://weathersearch-env.eba-vmsvqibd.us-west-1.elasticbeanstalk.com/location"
    var delegate: HttpRequestDelegate?
    var imageDelegate: ImageDelegate?
    func convertURL(link: String) -> URL {
        let urlStr : String = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let convertedURL : URL = URL(string: urlStr)!
        return convertedURL
    }
    func getCity(cityName: String) {
        let params: Parameters  = ["city": cityName];
        AF.request(autoCompleteURL,parameters: params,encoding: URLEncoding(destination: .queryString)).responseData { (response) -> Void in
            switch response.result {
            case .success(let data):
                if let cityData = self.parseCityJSON(cityData: data) {
                    self.delegate?.didGetCity(cityData: cityData)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    func getImage(cityName: String) {
        //let params: Parameters = ["address": cityName]
        SwiftSpinner.show("Fetching Google Images...")
        let city="Los%20Angeles"
        let url = "https://www.googleapis.com/customsearch/v1?cx=004574372782316189998:y3pkhtxd46f&imgSize=huge&q=los%20angeles%20beautiful&img_Type=news&search_Type=image&key=AIzaSyBX2yu-OegebXiNeabsw5ohXtpOi9_GhUM"
        print(" -----------" + cityName)
        AF.request(url,encoding: URLEncoding(destination: .queryString)).responseData { (response) -> Void in
            switch response.result {
            case .success(let data):
                print("here is good 1")
//                let image = self.parseImageJson(imageData: data)
//                print(image.items[0].pagemap.cse_image[0].src)
                if let image = self.parseImageJson(imageData: data) {
                    print(image.items[2].pagemap.cse_image[0].self)
                    print(image.items[0].kind)
                    self.imageDelegate?.didGetImage(image: image)

                }
                //.items[0].pagemap.cse_image[0]
            case .failure(let error):
                print(error)
            }
            SwiftSpinner.hide();
        }
    }
    func getLocation(description: String) {
        let index = description.firstIndex(of: ",")
        let cityName = description.prefix(upTo: index!)
        SwiftSpinner.show("Fetching Weather Details for " + cityName + "...")
        let params: Parameters  = ["address": description];
        AF.request(locationURL,parameters: params,encoding: URLEncoding(destination: .queryString)).responseData { (response) -> Void in
            switch response.result {
            case .success(let data):
                if let location = self.parseLocationJSON(locationData: data) {
                    let VC = ViewController()
                    VC.lat = location.lat
                    VC.lng = location.lng
                    self.delegate?.didGetLocation(location: location)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    func getWeather(lat: Double, lng: Double) {
        
        let params: Parameters  = ["lat": lat, "lng": lng];
        AF.request(weatherURL,parameters: params,encoding: URLEncoding(destination: .queryString)).responseData { (response) -> Void in
            switch response.result {
            case .success(let data):
                if let weather = self.parseWeatherJSON(weatherData: data) {
                    self.delegate?.didUpdateWeather(weather: weather)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    func getCurrentLocation() {
        SwiftSpinner.show("Loading...")
        AF.request("http://ip-api.com/json").responseData{
            (response) -> Void in
            switch response.result {
            case .success(let data):
                if let location = self.parseCurrentJson(currentData: data) {
                    self.delegate?.didGetCurrent(current: location)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    func parseCurrentJson(currentData: Data) -> CurrentData? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CurrentData.self, from: currentData)
            return decodedData
        } catch {
            print(error)
            return nil
        }
    }
    func parseImageJson(imageData: Data) -> ImageData? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ImageData.self, from: imageData)
            
            return decodedData
            
        } catch {
            print(error)
            return nil
        }
    }
    func parseWeatherJSON(weatherData: Data) -> WeatherDisplay? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let weather = WeatherDisplay(
                summary: decodedData.currently.summary,
                temperature: decodedData.currently.temperature,
                humidity: decodedData.currently.humidity,
                windSpeed: decodedData.currently.windSpeed,
                visibility: decodedData.currently.visibility,
                pressure: decodedData.currently.pressure,
                icon: decodedData.currently.icon,
                daily: decodedData.daily,
                prec: decodedData.currently.precipProbability,
                ozone: decodedData.currently.ozone,
                cc: decodedData.currently.cloudCover)
                SwiftSpinner.hide()
             return weather
        } catch {
            print(error)
            return nil
        }
       
    }
    func parseCityJSON(cityData: Data) -> CityData? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CityData.self, from: cityData)
            let cities = CityData(predictions: decodedData.predictions)
            return cities
            
        } catch {
            print(error)
            return nil
        }
       
    }
    func parseLocationJSON(locationData: Data) -> Location?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(LocationData.self, from: locationData)
            
            let lat = decodedData.results[0].geometry.location.lat
            let lng = decodedData.results[0].geometry.location.lng
            let loc = Location(lat: lat, lng: lng)
            SwiftSpinner.hide()
            return loc
        } catch {
            print(error)
            return nil
        }
    }

}
