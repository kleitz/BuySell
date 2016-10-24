//
//  PickMapLocationViewController.swift
//  esell
//
//  Created by Angela Lin on 10/23/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import MapKit


class PickMapLocationViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // This sets up the long tap to drop the pin.
        
        let longPressOnMap: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PickMapLocationViewController.didLongTapMap(_:)))
        longPressOnMap.delegate = self
        longPressOnMap.numberOfTapsRequired = 0
        longPressOnMap.minimumPressDuration = 0.5
        
        mapView.addGestureRecognizer(longPressOnMap)

        
    }


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

            }

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
