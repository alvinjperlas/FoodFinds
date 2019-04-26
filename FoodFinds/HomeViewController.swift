/*Icons made by <a href="https://www.freepik.com/?__hstc=57440181.421198ddb591addc4118ed18b56bca09.1556172164639.1556172164639.1556172164639.1&__hssc=57440181.1.1556172164639&__hsfp=2810556" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/"           title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"           title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>

*/



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
  let YELP_URL = "https://api.yelp.com/v3"
  let YELP_ENDPOINT_SEARCH = "/businesses/search"
  let headers = [
    "Authorization": "Bearer OPtj-IXqyJ2Qqtb1USWpc4xKqeyDAhrby8RJezJuRBFsGKeQwyh6XNlrMLlEe--_0zXOHbP5GPod_9krNU71ltbmLjGCEO8IYekZWj_c3D84o7dNIrMBbWlj4XoPW3Yx",
    "Content-Type": "application/json"
  ]

  var currentFilter = YelpSearchFilter(category: "", rating: 0,price: "0",open: true)
  var suggestedPlaces : [String:YelpDataModel] = [:] //business ID, data model.
 
  var asyncTaskList : [ DispatchWorkItem] = []
  var geotifications: [Geotification] = []
  var locationManager = CLLocationManager()
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var debuglabel2: UILabel!
  @IBOutlet weak var debuglabel: UILabel!
  @IBAction func zoomToCurrentLocation(sender: AnyObject) {
    mapView.zoomToUserLocation()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    mapView.zoomToUserLocation()
  }

  override func viewDidAppear(_ animated: Bool) {
     mapView.zoomToUserLocation()
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
      suggestionVC.suggestedPlaces = self.suggestedPlaces
    }
  }
  
  

  func getYelpData(mylocation: CLLocation) {
    let querystring = buildQuerystring(mylocation: mylocation)
    Alamofire.request(querystring, headers: self.headers).responseJSON {
      response in
      if response.result.isSuccess {
        let yelpJSON : JSON = JSON(response.result.value!)
        self.updateYelpResults(json: yelpJSON)
      }
      else {
        print("Error \(String(describing: response.result.error))")
      }
    }
  }
  
  
  func updateYelpResults(json: JSON){
    for result in json["businesses"].arrayValue {
      let isBusinessGoodEnough = Double(currentFilter.rating) <= result["rating"].doubleValue
      if !(suggestedPlaces[result["id"].stringValue] != nil) && isBusinessGoodEnough {
        //if business id is not yet stored, store it.
        //suggestedPlaces[result["id"].stringValue] = result
        let currentSearch = YelpDataModel()
        let currentCoordinate = YelpCoordinate()
        let currentLocation = YelpLocation()
        currentSearch.categoryList = []
        currentSearch.transaction = []
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
      }
    }
  }
  
  
  
  
  func buildQuerystring(mylocation: CLLocation) -> String{
    // Endpoints
    var fURL = self.YELP_URL + self.YELP_ENDPOINT_SEARCH
    fURL += "?longitude=\(mylocation.coordinate.longitude)&latitude=\(mylocation.coordinate.latitude)"
    fURL = ""==self.currentFilter.category ? fURL : "\(fURL)&term=\(self.currentFilter.category!)"
    fURL = "0"==self.currentFilter.price ?  fURL : "\(fURL)&price=\(self.currentFilter.price!)"
    fURL += "&open_now=\(self.currentFilter.open!)"
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
  }
  
  // MARK: Functions that update the model/associated views with geotification changes
  func add(_ geotification: Geotification) {
    geotifications.append(geotification)
    mapView.addAnnotation(geotification)
    addRadiusOverlay(forGeotification: geotification)
  }
  
  func remove(_ geotification: Geotification) {
    guard let index = geotifications.index(of: geotification) else { return }
    geotifications.remove(at: index)
    mapView.removeAnnotation(geotification)
    removeRadiusOverlay(forGeotification: geotification)
  }

  // MARK: Map overlay functions
  func addRadiusOverlay(forGeotification geotification: Geotification) {
    mapView?.add(MKCircle(center: geotification.coordinate, radius: geotification.radius))
  }

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




