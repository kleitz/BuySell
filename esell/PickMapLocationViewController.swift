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
        
        self.navigationItem.title = "Pickup Area"
        
        let searchButton = UIBarButtonItem(title: "Search", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(showSearchBar))
        
        navigationItem.rightBarButtonItem = searchButton
        
        
        
        // Location manager
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
        
        
        
        // This sets up the long tap to drop the pin.
        
        let longPressOnMap: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PickMapLocationViewController.didLongTapMap(_:)))
        longPressOnMap.delegate = self
        longPressOnMap.numberOfTapsRequired = 0
        longPressOnMap.minimumPressDuration = 0.5
        
        mapView.addGestureRecognizer(longPressOnMap)
  
    }
    
    
    
//    // MARK: ViewWillDisappear
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(true)
//
//        
//        print("VIEW IS DISAPPEARING::!!")
//        print("my parentivewcontrolerl is: \(self.presentingViewController)")
//        //        guard let presentingView = self.presentingViewController as? AddItemTableViewController! else {
//        //            fatalError()
//        //        }
//        
//       // parentView.pickupLat = mapView.annotations.first?.coordinate.latitude
//       // parentView.pickupLat = mapView.annotations.first?.coordinate.longitude
//    }
//    
    
    
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
            
            // any time annotation is added, also write to the previous view controller as an update
            
            saveAnnotationToPreviousViewController()

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
            
            // if has results, then draw on map with pin annotaiotn view
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(
                latitude: localSearchResponse!.boundingRegion.center.latitude,
                longitude: localSearchResponse!.boundingRegion.center.longitude
            )
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            
            // any time annotation is added, also write to the previous view controller as an update
            
            self.saveAnnotationToPreviousViewController()
            
            
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
    
    
    func saveAnnotationToPreviousViewController() {
        let count = self.navigationController!.viewControllers.count
        print("count of \(self.navigationController!.viewControllers.count)")
        print("here is the previous: \(self.navigationController!.viewControllers[count - 2])")
        
        if let previousVC = self.navigationController!.viewControllers[count - 2] as? AddItemTableViewController {
            previousVC.pickupLat = mapView.annotations.first?.coordinate.latitude
            previousVC.pickupLong = mapView.annotations.first?.coordinate.longitude
        }
        print(mapView.annotations.first?.coordinate)
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
