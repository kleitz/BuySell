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


// TODO Need to refactor. Fix handling of initiatlizing the post class later (don't use !). Or just add all guard let things in here so you don't have to write it every view controller.


class ItemListing: NSObject {
    
    var id: String
    var title: String
    var imageURL: String?
    var itemDescription: String
    var author: String
    
    var createdDate: NSDate
    
    var price: Double
    var pickupLatitude: Double
    var pickupLongitude: Double
    
    var canAcceptCreditCard: Bool
    var canShip: Bool
    
    //var location: String?
    
    
    // Computed variables for coordinate, subtitle, formattedPrice
    
    var coordinate: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2DMake(pickupLatitude, pickupLongitude)
    }
    
    var subtitle: String? {
        return itemDescription
    }
    
    var formattedPrice: String {
        let currencyLabel: String = "$ "
        
        //"%@%.2f ", [replace with var name],
        return String.localizedStringWithFormat("%@%.0f", currencyLabel, price)
    }
    
    
    
//    // TODO Failable initializer ? or not failable?
    init(id: String) {
        self.id = id
        self.title = ""
        self.author = ""
        self.imageURL = ""
        self.itemDescription = ""
        
        self.createdDate = NSDate()
        self.price = 0.0
        self.pickupLatitude = 0.0
        self.pickupLongitude = 0.0
        
        self.canAcceptCreditCard = false
        self.canShip = false
    }
    
    //TODO I added optional for double & the newer fields but this should be removed later
    // removed parameters , pickupLatitude: Double?, pickupLongitude: Double?, canAcceptCreditCard: Bool?, canShip: Bool?
    
    init(id: String, author: String, title: String, price: Double, itemDescription: String, createdDate: NSDate, pickupLatitude: Double, pickupLongitude: Double) {
        
        self.id = id
        self.author = author
        self.title = title
        self.price = price
        self.itemDescription = itemDescription
        self.createdDate = createdDate
        
        self.pickupLatitude = pickupLatitude
        self.pickupLongitude = pickupLongitude
        self.canAcceptCreditCard = false
        self.canShip = false
        
    }
    
}
