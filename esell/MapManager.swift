//
//  MapManager.swift
//  esell
//
//  Created by Angela Lin on 10/27/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import MapKit


class MapManager {
    enum MapError: ErrorType {
        
        case InvalidData
        case InvalidCountry
        case InvalidCity
        
    }
    
    func getCityFromCoordinate(coordinate: CLLocationCoordinate2D, completionHandler: (error: ErrorType?, city: String?) -> Void){
        
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
            
            
            
            guard let dictionary = placeMark.addressDictionary as? [String:AnyObject] else {
                completionHandler(error: MapError.InvalidData, city: nil)
                print("[MapManager] Error. couldnt get placeMark.addressDictionary ")
                return
            }
            
            // if user clicks on ocean , then it crashes because there is no country code
            
            guard let countryCode = dictionary["CountryCode"] as? String else {
                completionHandler(error: MapError.InvalidCountry, city: nil)
                return
            }
            
            
            switch countryCode {
                
            case "TW":
                // if Taiwan tehn use SubLocality: Nangang District or SubAdminsrtaitaiveArea..
                
                guard let adminArea = dictionary["SubAdministrativeArea"] as? NSString,
                    let city = dictionary["City"] as? NSString else {
                        print("[MapManager] error TW case: unable get district, city out of placed mark location")
                        completionHandler(error: MapError.InvalidCity, city: nil)
                        return
                }
                
                print("[MapManager]  Print.. sub adminarea-> \(adminArea), city-> \(city)")
                
                completionHandler(error: nil, city: "\(adminArea), \(city)")
                
                
            case "US":
                
                guard let state = dictionary["State"] as? NSString,
                    let city = dictionary["City"] as? NSString else {
                        print("[MapManager] eror US case: unable get data out of placed mark location")
                        completionHandler(error: MapError.InvalidCity, city: nil)
                        return
                }
                completionHandler(error: nil, city: "\(city), \(state)")
                
                
            default:
                
                guard let city = dictionary["City"] as? NSString,
                let state = dictionary["State"] as? NSString else {
                    
                    if let state = dictionary["State"] as? NSString {
                        completionHandler(error: nil, city: state as String)
                        
                    }
                    return
                }
            
                completionHandler(error: nil, city: "\(city), \(state)" as String)
            }
        }
        
        
//        func getLocationDictionaryFromCoordinate(coordinate: CLLocationCoordinate2D, completionHandler: (dictionary: [String:AnyObject]) -> Void){
//            
//            let geoCoder = CLGeocoder()
//            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//            
//            var locationDictInfo = [String:AnyObject]()
//            
//            
//            geoCoder.reverseGeocodeLocation(location) {
//                (placemarks, error) -> Void in
//                
//                let placeArray = placemarks as [CLPlacemark]!
//                
//                // Place details
//                var placeMark: CLPlacemark!
//                placeMark = placeArray?[0]
//                
//                // CLPlacemark has an Address dictionary property
//                print(placeMark.addressDictionary)
//                
//                
//                guard let dictionary = placeMark.addressDictionary as? [String:AnyObject] else {
//                    fatalError("convert location dict didn't work")
//                }
//                
//                locationDictInfo =  dictionary
//                
//            }
//            
//            completionHandler(dictionary: locationDictInfo)
//        }
    }
    
}
