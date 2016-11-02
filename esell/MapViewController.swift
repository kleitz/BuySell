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


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    
    var sourceViewController = PostTabBarController()
    
    var posts = [ItemListing]()
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        print("VIEW WILL APPEAR")
        
        self.tabBarController?.setTabBarVisible(true, animated: true)
        
        posts = []
        
        sourceViewController = self.parentViewController?.tabBarController as! PostTabBarController
        
        for post in sourceViewController.posts {
            
            posts.append(post)
            
        }
        
        print("print posts \(posts)")
        print(" print # of posts \(posts.count)")
        
        
        for post in posts {
            let location = post.coordinate
            
            let coordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let point: MKPointAnnotation = MKPointAnnotation()
            point.coordinate = coordinates
            point.title = post.title
            point.subtitle = post.itemDescription
            // pinAnnotationView = MKPinAnnotationView(annotation: point, reuseIdentifier: "pickupLocation")
            mapView.addAnnotation(point)
            
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up title
        
        self.navigationItem.title = "Map"
        
        
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

        
    }
    
    
    // MARK: functions
    
    // Everytime (any) location is updated, this function is called?
    
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
    
    
    // CLLocationManagerDelegate method. Called by CLLocationManager when access to authorisation changes.

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


    
    // MARK: - Custom Annotation (MKMapViewDelegate method). Called when the map view needs to display the annotation.
    // E.g. If you drag the map so that the annotation goes offscreen, the annotation view will be recycled. When you drag the annotation back on screen this method will be called again to recreate the view for the annotation.

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        switch annotation {
        case is MKUserLocation:
            return nil
            
        case is MKPointAnnotation:
            let reuseId = "pickupLocation"
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            annotationView!.rightCalloutAccessoryView = UIButton(type: .InfoLight)

            annotationView!.canShowCallout = true
            annotationView!.image = UIImage(named: "shopbag_transparent")
            
            return annotationView
            
        default: return nil
            
            
        }

    }
    
    
    // MARK: - Navigation
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("test that callout accessory button thing tapped")
        
        self.performSegueWithIdentifier("segueMapToItemDetail", sender: view)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print(" >> started segue")
        
        if let identifier = segue.identifier {
            
            switch identifier {
                
                
            case "segueMapToItemDetail":
                print("going to map")
                print("sender is \(sender)")
                // pass the stuff here. need the post ID or something so that can find it to show in detail view.
                
                guard let itemDetailController = segue.destinationViewController as? ItemDetailViewController else {
                    fatalError("seg failed")
                }
                
                
                if let info = sender as? MKAnnotationView {
                    print("test print cusotmpoint annotiaotn value \(info.annotation?.title)")
                    
                    if let title = info.annotation?.title ?? "" {
                        
                        var indexNum: Int?
                        
                        for post in posts {
                       
                            if title == post.title {
                                indexNum = posts.indexOf(post)!
                                print("is this the post index \(posts.indexOf(post))")
                            }
                        }
                        guard let index = indexNum else {
                            print("fail getting optional in segue")
                            return
                        }
                        // pass the post info to itemDetailView
                        itemDetailController.post = posts[index]
                        
                        // for passing image
                        if let image: UIImage = sourceViewController.imageCache[sourceViewController.posts[index].imageURL!] {
                            itemDetailController.image = image
                        }
                    }
                }
                
            default: break
            }
            
        }
    }

}
