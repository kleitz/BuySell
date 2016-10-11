//
//  ItemListing.swift
//  esell
//
//  Created by Angela Lin on 9/28/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ItemListing: NSObject {
    
    var title: String?
    
    var imageURL: String?

    var price: String?
    
    var itemDescription: String?
    
    var location: String?
    
    var author: String?
    
    var createdDate: NSDate?
    
    var pickupLatitude: Double?
    
    var pickupLongitude: Double?
    
    var coordinate: CLLocationCoordinate2D {
        
        guard let lat = pickupLatitude else {
            
            // TODO fix handling later
            fatalError()
        }
        guard let long  = pickupLongitude else {
            fatalError()
        }
        
        return CLLocationCoordinate2DMake(lat, long)
    }
    
    var subtitle: String? {
        return itemDescription
    }
    
    var acceptOnlinePayment: Bool?
    
    var acceptShippingOption: Bool?
    
    
}
