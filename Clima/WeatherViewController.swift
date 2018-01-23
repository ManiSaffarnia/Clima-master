//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "409307f32ecf4c72f18a6eaed6e37e62"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureSwitch: UISwitch!
    @IBOutlet weak var currentLocationLabel: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String:String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess{
                //print("Successful! get the data")
                let jsonResult: JSON = JSON(response.result.value!)
                //print(jsonResult)
                self.updateWeatherData(jsonData: jsonResult)
            }
            else{
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issue"
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(jsonData: JSON){
        
        if let temprature = jsonData["main"]["temp"].double{
            let convertedTemprature = temprature - 273.15
            weatherDataModel.temperature = Int(convertedTemprature)
            
            weatherDataModel.city = jsonData["name"].stringValue
            
            weatherDataModel.condition = jsonData["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            //pass the data to the UIupdate function
            updateUIWithWeatherData(weatherData: weatherDataModel)
        }
        else{
            print("there is a problem with API response")
            print(jsonData)
            cityLabel.text = "weather Unavailable"
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(weatherData: WeatherDataModel){
        cityLabel.text = weatherData.city
        temperatureLabel.text =  temperatureSwitch.isOn ? "\(weatherData.temperature)º" : "\(Int((Double(weatherData.temperature) * 1.8)+32))℉"
        weatherIcon.image = UIImage(named: weatherData.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            //locationManager.delegate = nil
            //print("latitude = \(location.coordinate.latitude) Longitude = \(location.coordinate.longitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let param : [String:String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: param)
        }
    }
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnterANewCity(city: String) {
        let param : [String : String] = ["q" : city, "appid" : APP_ID]
        currentLocationLabel.setImage(UIImage(named: "location-insideWhite"), for: .normal)
        getWeatherData(url: WEATHER_URL, parameters: param)
        
        
    }
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCitySegue" {
            let nextVC = segue.destination as! ChangeCityViewController
            nextVC.delegate = self
        }
    }
    
    
    
    //MARK: - convert the temprature
    /***************************************************************/
    
    @IBAction func convertSwitchPressed(_ sender: UISwitch) {
        if temperatureSwitch.isOn{
            temperatureLabel.text = "\(weatherDataModel.temperature)º"
            //print(temperatureLabel.text)
        }
        else{
            temperatureLabel.text = "\(Int((Double(weatherDataModel.temperature) * 1.8) + 32))℉"
            //print(temperatureLabel.text)
        }
    }
    
    
    //MARK: - current location button
    /***************************************************************/
    
    @IBAction func currentLocationButtonPressed(_ sender: UIButton) {
        currentLocationLabel.setImage(UIImage(named: "location"), for: .normal)
        locationManager.startUpdatingLocation()
    }
    
    
    
    
}


