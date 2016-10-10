//
//  MapViewController.swift
//  esell
//
//  Created by Angela Lin on 10/7/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import MapKit
import Firebase


class MapViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up title
        self.navigationItem.title = "Local Map"
        
        // Location manager
   
        
        
        // Use CLLocation Manager to get current location
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        // TO DO Fetch posts from other tab or new fetch call. 
        // then read the coord of each post (optional) and if it exists then show on the map
        
    
        
    }
    
    
    // MARK: functions
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("location: \(locations)")
        // to do : fix !
        
//        guard let locations = locations else {
//            print("error")
//            return
//        }
        let location = locations.last! as CLLocation ?? CLLocation(latitude: 0,longitude: 0)
        
        //let locationAs2d = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        
        // example of adding a placemark to the map - 
        /// TODO this needs to be clickable and open to the item detail view
        
        let exampleCoordinate = CLLocationCoordinate2D(latitude: 25.0493015, longitude: 121.5347545)
        
        let mapItem = MKPlacemark(coordinate: exampleCoordinate, addressDictionary: nil)
        
        mapView.addAnnotation(mapItem)

        
        // stop updating
        
        locationManager.stopUpdatingLocation()
        
        // set region zoom
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        self.mapView.setRegion(region, animated: true)
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("ERROR location manager: \(error.localizedDescription)")
    }
    
    
    // func to get coordinates out of Firebase
    
    func fetchPostsWithCoordinates() {
        
        //let ref = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com/")
        
        // ref.child
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
