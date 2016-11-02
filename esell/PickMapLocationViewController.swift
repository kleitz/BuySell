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
    
    
    @IBOutlet weak var checkmarkImage: UIImageView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var locationManager: CLLocationManager!
    
    var searchController:UISearchController!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
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
        
        
        // test
        self.searchBar.delegate = self
        
        
        
        // Set up title
        
        self.navigationItem.title = "" // TODO I think should replace with image instead of text here
        
        // Init the zoom level
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 34.03, longitude: 118.14)
        let span = MKCoordinateSpanMake(100, 80)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.mapView.setRegion(region, animated: true)
        
        
        // Setup label/checkmark icon
        self.locationLabel.text = "Touch map or search to pin your city"
        self.checkmarkImage.hidden = true
        
        
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
        
        //let searchButton = UIBarButtonItem(title: "Search", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(showSearchBar))
        
       // navigationItem.rightBarButtonItem = searchButton
        
        
        // Set up Label to show when user pins a location
        
        
        
        
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
        
        let lastLocation = locations.last
        
        guard let currentLocation = lastLocation else {
            print("Error getting location")
            return
        }
        
        // stop updating because should have gotten location at least once
        
        locationManager.stopUpdatingLocation()
        
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
    
//    
//    func showSearchBar(){
//        
//        searchController = UISearchController(searchResultsController: nil)
//        searchController.hidesNavigationBarDuringPresentation = false
//        self.searchController.searchBar.delegate = self
//        self.presentViewController(searchController, animated: true, completion: nil)
//    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        
        // dismiss search bar and present search results
        searchBar.resignFirstResponder()
        
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
        self.checkmarkImage.hidden = true
        self.locationLabel.text = ""
        self.activityIndicator.startAnimating()
        
        // This takes the navigation stack and goes to get a ref to the previous controller
        
        let count = self.navigationController!.viewControllers.count
        
        guard let previousVC = self.navigationController!.viewControllers[count - 2] as? AddItemTableViewController else {
            print("[saveAnnotToPrevVC] ERROR getting reference to previous vc")
            // TODO do a popup? or already handled in the previous vc..
            return
        }
        
        // Set data for the previous VC
        previousVC.pickupLat = pickUpLocationCoordinate.latitude
        previousVC.pickupLong = pickUpLocationCoordinate.longitude
        
        saveNearestCityNameFromCoordinate(pickUpLocationCoordinate)
    }
    
    func saveNearestCityNameFromCoordinate(coordinate: CLLocationCoordinate2D){
        
        // also get and save the nearest city/location name
        let mapManager = MapManager()
        
        mapManager.getCityFromCoordinate(coordinate) { (error, city) in
            
            
            // if there is an eror, then popup message
            
            if let error = error {
                
                print(error)
                self.popupNotifyIncomplete("Error getting location, try again")
                
            }
            
            // if no error, then use city
            if let city = city {
                print("IN COMPLETION HANDLER: \(city)")
                // send data to previous VC
                
                let count = self.navigationController!.viewControllers.count
                
                guard let previousVC = self.navigationController!.viewControllers[count - 2] as? AddItemTableViewController else {
                    print("[saveAnnotToPrevVC] ERROR getting reference to previous vc")
                    // TODO do a popup? or already handled in the previous vc..
                    return
                }
                
                previousVC.pickupLocationText = city as String
                
                previousVC.selectPickupText.textColor = UIColor.blackColor()
                
                // update current view's label
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.locationLabel.text = "\(city)"
                    
                    self.checkmarkImage.hidden = false
                    
                    self.locationLabel.setNeedsDisplay()
                    
                    
                })
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
    
    
    func popupNotifyIncomplete(errorMessage: String) {
        
        let alertController = UIAlertController(title: "Wait!", message: errorMessage, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
   
    
    
    deinit{
        
        print("[deinit] killed PickMap")
    }

}
