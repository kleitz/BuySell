//
//  MapManager.swift
//  esell
//
//  Created by Angela Lin on 10/27/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import MapKit

class MapManager {
    
    
    func getCityFromCoordinate(coordinate: CLLocationCoordinate2D, completionHandler: (city: String) -> Void){
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            // CLPlacemark has an Address dictionary property
            print(placeMark.addressDictionary)
            
            // if US then use city, state
            
            
            // if Taiwan tehn use SubLocality: Nangang District
            guard let dictionary = placeMark.addressDictionary as? [String:AnyObject] else {
                fatalError("convert location dict didn't work")
            }
            
            guard let countryCode = dictionary["CountryCode"] as? String else {
                fatalError("convert dict's country code didn't work")
            }
            
            
            switch countryCode {
                
            case "TW":
                guard let adminArea = dictionary["SubAdministrativeArea"] as? NSString,
                    let city = dictionary["City"] as? NSString else {
                        print("map: error getting district, city out of placed mark location")
                        return
                }
                
                print("Print.. sub adminarea-> \(adminArea), city-> \(city)")
                
                completionHandler(city: "\(adminArea), \(city)")
                
                
            case "US":
                
                guard let state = dictionary["State"] as? NSString,
                    let city = dictionary["City"] as? NSString else {
                        print("map: error getting data out of placed mark location")
                        return
                }
                completionHandler(city: "\(city), \(state)")
                
                
            default:
                
                guard let city = dictionary["City"] as? NSString else {
                    print("map: error getting district, city out of placed mark location")
                    return
                    
                }
                
                completionHandler(city: city as String)
                
            }
        }
        
        
        func getLocationDictionaryFromCoordinate(coordinate: CLLocationCoordinate2D, completionHandler: (dictionary: [String:AnyObject]) -> Void){
            
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            var locationDictInfo = [String:AnyObject]()
            
            
            geoCoder.reverseGeocodeLocation(location) {
                (placemarks, error) -> Void in
                
                let placeArray = placemarks as [CLPlacemark]!
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                
                // CLPlacemark has an Address dictionary property
                print(placeMark.addressDictionary)
                
                
                guard let dictionary = placeMark.addressDictionary as? [String:AnyObject] else {
                    fatalError("convert location dict didn't work")
                }
                
                locationDictInfo =  dictionary
                
            }
            
            completionHandler(dictionary: locationDictInfo)
        }
    }
    
}
