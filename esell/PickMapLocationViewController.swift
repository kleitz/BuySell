//
//  PickMapLocationViewController.swift
//  esell
//
//  Created by Angela Lin on 10/23/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import MapKit


class PickMapLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate {
    
    
    //MARK: IBOutlets & map vars
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var displayLocationLabel: UILabel!
    
    
    var locationManager: CLLocationManager!
    
    var searchController:UISearchController!
    
    var annotation:MKAnnotation!
    
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    
    
    //MARK: ViewDidLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up title
        
        self.navigationItem.title = "" // TODO I think should replace with image instead of text here
        

        // Use CLLocation Manager to get current location
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            mapView.delegate = self
            mapView.mapType = MKMapType.Standard
            
            
            // if authorized , start updating location
            switch CLLocationManager.authorizationStatus() {
                
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                locationManager.startUpdatingLocation()
                
            // if not authorized, then request authorization for "when in use"
            default:
                locationManager.requestWhenInUseAuthorization()
                
            }
            
            
        }
        
        
        // Set up serach button as rightBarButton
        
        let searchButton = UIBarButtonItem(title: "Search", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(showSearchBar))
        
        navigationItem.rightBarButtonItem = searchButton
        
        
        // Set up Label to show when user pins a location
        
        displayLocationLabel.text = ""
        
        
        
        
        
        
        
        
        // This sets up the long tap to drop the pin.
        
        let longPressOnMap: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PickMapLocationViewController.didLongTapMap(_:)))
        longPressOnMap.delegate = self
        longPressOnMap.numberOfTapsRequired = 0
        longPressOnMap.minimumPressDuration = 0.5
        
        mapView.addGestureRecognizer(longPressOnMap)
  
    }
    
    
    
    // MARK:- Functions
    
    func didLongTapMap(gestureRecognizer: UIGestureRecognizer) {
        
        // Get the spot that was tapped.
        let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)

        print("cooridnates: \(touchMapCoordinate)")
        
        
        // if the gestureRecognizer receives what is defined as a new gesture
        
        if .Began == gestureRecognizer.state {
            
            // Delete any existing annotations.
            
            if mapView.annotations.count != 0 {
                mapView.removeAnnotations(mapView.annotations)
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchMapCoordinate
            
            mapView.addAnnotation(annotation)
            
            /// SAVE map annotation
//            
//            let test = getClosestCityFromCoordinate(annotation.coordinate)
//            
//            print("test: \(test)")
            
            saveAnnotationToPreviousViewController(annotation.coordinate)

        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(" -- location gotten: \(locations)")
        
        let lastLocation = locations.last
        
        guard let currentLocation = lastLocation else {
            print("Error getting location")
            return
        }
        
        // stop updating because should have gotten location at least once
        
        locationManager.stopUpdatingLocation()
        print(" -- stop updating location")
        
        
        // set region zoom
        let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.setRegion(region, animated: true)
        
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("ERROR location manager: \(error.localizedDescription)")
    }
    
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
            
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            // Location services are authorised, track the user.
            locationManager?.startUpdatingLocation()
            
            mapView.showsUserLocation = true
            
        case .Denied, .Restricted:
            // Location services not authorised, stop tracking the user.
            locationManager?.stopUpdatingLocation()
            mapView.showsUserLocation = false
            
            
        default:
            locationManager?.stopUpdatingLocation()
            mapView.showsUserLocation = false
        }
    }
    
    
    func showSearchBar(){
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.presentViewController(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        
        // dismiss search bar and present search results
        searchBar.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        // search bar text query
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        
        localSearch.startWithCompletionHandler( { (localSearchResponse, error) in
            
            if localSearchResponse == nil {
                
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            // if has results,
            
            // Delete any existing annotations.
            
            if self.mapView.annotations.count != 0 {
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
            
            // then draw on map with pin annotation view
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(
                latitude: localSearchResponse!.boundingRegion.center.latitude,
                longitude: localSearchResponse!.boundingRegion.center.longitude
            )
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            
            
//            if let myAnnotation = self.mapView.annotations.first {
//                
//                let myCoordinate = myAnnotation.coordinate
//                /// SAVE map annotation - this is where data is passed
//                self.saveAnnotationToPreviousViewController(self.pointAnnotation.coordinate)
//            }
            
            self.saveAnnotationToPreviousViewController(self.pointAnnotation.coordinate)
            
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(self.pointAnnotation.coordinate, span)
            self.mapView.setRegion(region, animated: true)
            
            
        })
   
    }
    
    
    // Popup alert if missing fields
    
    func popupNotifyIncomplete(){
        
        let alertController = UIAlertController(title: "Choose a location first!", message:
            "Drop a marker by pressing down on map or use Search", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { action in
            print("test: pressed Dismiss")
        }))
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // SAVE DATA - any time annotation is added, also write to the previous view controller as an update
    
    func saveAnnotationToPreviousViewController(pickUpLocationCoordinate: CLLocationCoordinate2D) {
        
        // This takes the navigation stack and goes to get a ref to the previous controller
        
        let count = self.navigationController!.viewControllers.count
        
        guard let previousVC = self.navigationController!.viewControllers[count - 2] as? AddItemTableViewController else {
            print("[saveAnnotToPrevVC] ERROR getting reference to previous vc")
            // TODO do a popup? or already handled in the previous vc..
            return
        }
        
      
        previousVC.pickupLat = pickUpLocationCoordinate.latitude
        previousVC.pickupLong = pickUpLocationCoordinate.longitude
     
        
        // also save the nearest city/location name
        self.getClosestCityFromCoordinate(pickUpLocationCoordinate)
        
        
    }
    
    
    func getClosestCityFromCoordinate(myCoordinate: CLLocationCoordinate2D) -> [String:AnyObject]  {
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: myCoordinate.latitude, longitude: myCoordinate.longitude)
        
        var locationDictInfo = [String:AnyObject]()
        
        
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            // CLPlacemark has an Address dictionary
            print(placeMark.addressDictionary)
            
            /* Optional([Street: Navy HQ Road, SubAdministrativeArea: Taipei City, State: Taipei, CountryCode: TW, ZIP: 104, Thoroughfare: Navy HQ Road, Name: Navy HQ Road, Country: Taiwan, FormattedAddressLines: <__NSArrayM 0x170849d50>(
            Navy HQ Road,
            Taipei, Taipei City 104,
            Taiwan
            )
             , City: Taipei])
             
             Optional([SubAdministrativeArea: Essex, CountryCode: US, SubLocality: Newark Airport and Port Newark, State: NJ, Street: 104-112 Lister Ave, ZIP: 07105, Name: 104-112 Lister Ave, Thoroughfare: Lister Ave, FormattedAddressLines: <__NSArrayM 0x176044230>(
             104-112 Lister Ave,
             Newark, NJ  07105,
             United States
             )
             
             Optional([SubLocality: Kamiyanagi, Street: Kamiyanagi, State: Saitama, CountryCode: JP, Thoroughfare: Kamiyanagi, Name: Kamiyanagi, Country: Japan, FormattedAddressLines: <__NSArrayM 0x172845580>(
             Kamiyanagi,
             Kasukabe, Saitama,
             Japan
             )
             , City: Kasukabe])
             */
            
            
            guard let dictionary = placeMark.addressDictionary as? [String:AnyObject] else {
                fatalError("convert location dict didn't work")
            }
            
            
            if let city = placeMark.addressDictionary?["City"] as? NSString
            {
                print(city)
            }
            
            if let district = placeMark.addressDictionary?["SubLocality"] as? NSString
            {
                print(district)
                self.displayLocationLabel.text = "\(district)"
            }
            
            
            if let adminArea = placeMark.addressDictionary?["SubAdministrativeArea"] as? NSString
            {
                print(adminArea)

            }

            
            locationDictInfo = dictionary
            
            print("test print the dict \(locationDictInfo["City"])")
        }
        
        return locationDictInfo
        
        
    }
    

    
}
