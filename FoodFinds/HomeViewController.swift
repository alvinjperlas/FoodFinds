//
//  Created by Alvin Perlas on 2/15/19.
//  Copyright © 2019 alvinperlas. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import MapKit

class HomeViewController: UIViewController, CLLocationManagerDelegate, FiltersDelegate {
    
    //Temp
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let YELP_CLIENTID = "VgKiArW_QzF_M0scNN5CMg"
    let YELP_APIKEY = "OPtj-IXqyJ2Qqtb1USWpc4xKqeyDAhrby8RJezJuRBFsGKeQwyh6XNlrMLlEe--_0zXOHbP5GPod_9krNU71ltbmLjGCEO8IYekZWj_c3D84o7dNIrMBbWlj4XoPW3Yx"
    let YELP_APPNAME = ""
    
  
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    @IBOutlet weak var faren: UISwitch!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!


    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
     
    }
       
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func `switch`(_ sender: UISwitch) {
        
        if sender.isOn {
            
        }
    }
    
    
    //MARK: - Networking
    /***************************************************************/

    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    

    
    
    
    
    

    func updateWeatherData(json : JSON) {
    
        let tempResult = json["main"]["temp"].doubleValue
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            updateUIWithWeatherData()
        }
    
    
    
    
    //MARK: - UI Updates
    /***************************************************************/

    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/

    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Delegate methods
    /***************************************************************/
    func userEnteredFilter(data: YelpSearchFilter) {
        // TO DO
        // Integrate YELP API
    }
    
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "applyFilters" {
            let destinationVC = segue.destination as! FiltersViewController
            destinationVC.delegate = self
        }
    }
}











