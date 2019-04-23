
import UIKit
import MapKit
import CoreLocation
  import SwiftyJSON
import Alamofire






struct PreferencesKeys {
  static let savedItems = "savedItems"
}



protocol DataUpdateDelegage {
  
  func newData(yelpdata: YelpDataModel)
  
}


class HomeViewController: UIViewController {
  
  
  var delegate : DataUpdateDelegage?
 //  delegate?.newData(data: searchFilter)
  
  
  let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
  let APP_ID = "e72ca729af228beabd5d20e3b7749713"
  
  let YELP_CLIENTID = "VgKiArW_QzF_M0scNN5CMg"
  
  let headers = [
    "Authorization": "Bearer OPtj-IXqyJ2Qqtb1USWpc4xKqeyDAhrby8RJezJuRBFsGKeQwyh6XNlrMLlEe--_0zXOHbP5GPod_9krNU71ltbmLjGCEO8IYekZWj_c3D84o7dNIrMBbWlj4XoPW3Yx",
    "Content-Type": "application/json"
  ]
  let YELP_URL = "https://api.yelp.com/v3"
  let YELP_ENDPOINT_SEARCH = "/businesses/search"

   var currentFilter = YelpSearchFilter(category: "", rating: 0,price: "0",open: true)
  var suggestedPlaces : [String:YelpDataModel] = [:] //business ID, data model.
  @IBOutlet weak var mapView: MKMapView!
  
  var asyncTaskList : [ DispatchWorkItem] = []
  var geotifications: [Geotification] = []
  var locationManager = CLLocationManager()
  
  
    @IBOutlet weak var debuglabel2: UILabel!
    
    @IBOutlet weak var debuglabel: UILabel!
    
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()

   // loadAllGeotifications()
   // locationManager.startUpdatingLocation()
    mapView.zoomToUserLocation()
  }

  override func viewDidAppear(_ animated: Bool) {
     mapView.zoomToUserLocation()
  }
  
  
  
  
  
  
  
  
  
  // MARK: Functions that update the model/associated views with geotification changes
  func add(_ geotification: Geotification) {
    geotifications.append(geotification)
    mapView.addAnnotation(geotification)
    addRadiusOverlay(forGeotification: geotification)
    //updateGeotificationsCount()
  }
  
  
  
  
  
  func remove(_ geotification: Geotification) {
    guard let index = geotifications.index(of: geotification) else { return }
    geotifications.remove(at: index)
    mapView.removeAnnotation(geotification)
    removeRadiusOverlay(forGeotification: geotification)
    //updateGeotificationsCount()
  }
  
  
  

  
  
  // MARK: Map overlay functions
  func addRadiusOverlay(forGeotification geotification: Geotification) {
    mapView?.add(MKCircle(center: geotification.coordinate, radius: geotification.radius))
  }
  
  // MARK: Other mapview functions
  @IBAction func zoomToCurrentLocation(sender: AnyObject) {
    mapView.zoomToUserLocation()
  }
  
  
  
  
//
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    if segue.identifier == "addGeotification" {
//      let navigationController = segue.destination as! UINavigationController
//      let vc = navigationController.viewControllers.first as! AddGeotificationViewController
//      vc.delegate = self
//    }
//  }
  
  

  
  
  func removeRadiusOverlay(forGeotification geotification: Geotification) {
    // Find exactly one overlay which has the same coordinates & radius to remove
    guard let overlays = mapView?.overlays else { return }
    for overlay in overlays {
      guard let circleOverlay = overlay as? MKCircle else { continue }
      let coord = circleOverlay.coordinate
      if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
        mapView?.remove(circleOverlay)
        break
      }
    }
  }
  
  
  
  
  
  
  
  
}











extension HomeViewController : FiltersDelegate{
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "updateYelpFilter" {
      let destinationVC = segue.destination as! FiltersViewController
      destinationVC.delegate = self
    }
    
    else if segue.identifier == "seeSuggestions"{
      let suggestionVC = segue.destination as! SuggestionsViewController
      //suggestionVC.datadelegate = self
     suggestionVC.suggestedPlaces = self.suggestedPlaces
    }
  }
  
  

  func getYelpData(mylocation: CLLocation) {
    let querystring = buildQuerystring(mylocation: mylocation)
    Alamofire.request(querystring, headers: self.headers).responseJSON {
      response in
      if response.result.isSuccess {
        print("Success! GotYELPdata")
        let yelpJSON : JSON = JSON(response.result.value!)
        self.updateYelpResults(json: yelpJSON)
        print(yelpJSON)
      }
      else {
        print("Error \(String(describing: response.result.error))")
      }
    }
  }
  
  
  func updateYelpResults(json: JSON){
    //for (key, subJson): (String, JSON) in json["businesses"]{}
    for result in json["businesses"].arrayValue {
      if !(suggestedPlaces[result["id"].stringValue] != nil) {
        //if business id is not yet stored, store it.
        //suggestedPlaces[result["id"].stringValue] = result
        let currentSearch = YelpDataModel()
        let currentCoordinate = YelpCoordinate()
        let currentLocation = YelpLocation()
        
        currentSearch.categoryList = []
        currentSearch.transaction = []
        //let currCategory = YelpCategory()
        
        currentSearch.name = result["name"].stringValue
        currentSearch.is_closed = result["is_closed"].boolValue
        currentSearch.alias = result["alias"].stringValue
        currentSearch.businessID = result["id"].stringValue
        currentSearch.displayPhone = result["display_phone"].stringValue
        currentSearch.distance = result["distance"].doubleValue
        currentSearch.phone = result["phone"].stringValue
        currentSearch.price = result["price"].stringValue
        currentSearch.rating = result["rating"].doubleValue
        currentSearch.review_count = result["review_count"].intValue
        currentSearch.image_url = result["image_url"].stringValue
        currentSearch.url = result["url"].stringValue
        
        for categoryEntry in result["categories"].arrayValue{
          currentSearch.categoryList.append(categoryEntry["alias"].stringValue)
          currentSearch.categoryList.append(categoryEntry["title"].stringValue)
        }
        
        currentCoordinate.latitude = result["coordinates"]["latitude"].doubleValue
        currentCoordinate.longitude = result["coordinates"]["longitude"].doubleValue
        
        currentSearch.coordinate = currentCoordinate
        for trans in result["transactions"].arrayValue{
          currentSearch.transaction.append(trans.stringValue)
        }
        
        currentLocation.address1 = result["location"]["address1"].stringValue
        currentLocation.address2 = result["location"]["address2"].stringValue
        currentLocation.address3 = result["location"]["address3"].stringValue
        currentLocation.city = result["location"]["city"].stringValue
        currentLocation.zip_code = result["location"]["zip_code"].stringValue
        currentLocation.country = result["location"]["country"].stringValue
        currentLocation.state = result["location"]["state"].stringValue
        
        currentSearch.location = currentLocation
        suggestedPlaces[currentSearch.businessID] = currentSearch
        
        
        //delegate?.newData(yelpdata: currentSearch)
      }
    }
  }
  
  
  
  
  func buildQuerystring(mylocation: CLLocation) -> String{
    // Endpoints
    var fURL = self.YELP_URL + self.YELP_ENDPOINT_SEARCH
    // Coordinates
    fURL += "?longitude=\(mylocation.coordinate.longitude)&latitude=\(mylocation.coordinate.latitude)"
    
    // Term
    fURL += ""==self.currentFilter.category ? "" : "\(fURL)&term=\(self.currentFilter.category!)"
    
    //Price
    fURL += "0"==self.currentFilter.price ?  "" : "&price=\(self.currentFilter.price!)"
    
    //IsOpen
    fURL += "&open_now=\(self.currentFilter.open!)"
    
    print(fURL)
    return fURL
  }
  
  
  
  
  func userEnteredFilter(data: YelpSearchFilter)  {
    self.currentFilter = data
    activateLocationTrackingTimer()
  }
  
  
  

  
  func activateLocationTrackingTimer(){
    // Reset all tracking timer whenever a new filter has been created.
    for tasks in asyncTaskList{
      tasks.cancel()
    }
    let newtasks = DispatchWorkItem {  self.locationManager.stopUpdatingLocation() }
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 60, execute: newtasks)
    asyncTaskList.append(newtasks)
    locationManager.startUpdatingLocation()
  }
}





//  // (YelpSearchFilter.category)&"
//  Alamofire.request(YELP_URL + YELP_ENDPOINT_SEARCH, headers: headers).responseJSON { response in
//  debugPrint(response)
//  }

//    let tempResult = json["main"]["temp"].doubleValue
//    weatherDataModel.temperature = Int(tempResult - 273.15)
//    weatherDataModel.city = json["name"].stringValue
//    weatherDataModel.condition = json["weather"][0]["id"].intValue
//    updateUIWithWeatherData()
// Need to set preference in here only?
//getYelpData(url: self.YELP_URL + self.YELP_ENDPOINT_SEARCH, filterData: YelpSearchFilter)
//
//  let turnOffTimer;
//
//  turnOffTimer= DispatchWorkItem { print("do something") }
//
//  // execute task in 2 seconds
//  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: task)
//
//  // optional: cancel task
//  task.cancel()
// Turn Off location tracking after 20 mins.
//    DispatchQueue.main.asyncAfter(deadline: .now() + 1200) {
//      self.locationManager.stopUpdatingLocation()
//    }








// MARK: AddGeotificationViewControllerDelegate
extension HomeViewController: AddGeotificationsViewControllerDelegate {
  
  func addGeotificationViewController(_ controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: Geotification.EventType) {
    controller.dismiss(animated: true, completion: nil)
    let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
    let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
    add(geotification)
    //startMonitoring(geotification: geotification)
    //saveAllGeotifications()
  }
  
}














// MARK: - Location Manager Delegate
extension HomeViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    mapView.showsUserLocation = status == .authorizedAlways
  }
  
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("Monitoring failed for region with identifier: \(region!.identifier)")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location Manager failed with the following error: \(error)")
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations[locations.count - 1]
    if location.horizontalAccuracy > 0 {
        //locationManager.stopUpdatingLocation()
        debuglabel.text = "long= \(location.coordinate.longitude)"
        debuglabel2.text = "lat= \(location.coordinate.latitude)"
      mapView.zoomToUserLocation()
      getYelpData(mylocation: location)
      
      
    }

  }
}

















// MARK: - MapView Delegate
extension HomeViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier = "myGeotification"
    if annotation is Geotification {
      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView?.canShowCallout = true
        let removeButton = UIButton(type: .custom)
        removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        removeButton.setImage(UIImage(named: "DeleteGeotification")!, for: .normal)
        annotationView?.leftCalloutAccessoryView = removeButton
      } else {
        annotationView?.annotation = annotation
      }
    return annotationView
    }
    return nil
  }
  
  
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKCircle {
      let circleRenderer = MKCircleRenderer(overlay: overlay)
      circleRenderer.lineWidth = 1.0
      circleRenderer.strokeColor = .purple
      circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
      return circleRenderer
    }
    return MKOverlayRenderer(overlay: overlay)
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    // Delete geotification
    let geotification = view.annotation as! Geotification
    remove(geotification)
    //saveAllGeotifications()
  }
  
}
