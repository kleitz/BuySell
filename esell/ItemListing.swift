//
//  ItemListing.swift
//  esell
//
//  Created by Angela Lin on 9/28/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import Foundation
import MapKit
import Firebase


// TODO Need to refactor. Fix handling of initiatlizing the post class later (don't use !). Or just add all guard let things in here so you don't have to write it every view controller.


class ItemListing: NSObject {
    
    var id: String
    var title: String
    var imageURL: String?
    var itemDescription: String
    var author: String
    
    var pickupDescription: String
    
    var createdDate: NSDate
//    {
//        return NSDate(timeIntervalSince1970: createdDateTimeInterval)
//    }

    var price: Double
    var pickupLatitude: Double
    var pickupLongitude: Double
    
    var canAcceptCreditCard: Bool
    var canShip: Bool
    
    
    // Computed variables for coordinate, subtitle, formattedPrice
    
    var coordinate: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2DMake(pickupLatitude, pickupLongitude)
    }
    
    var subtitle: String? {
        return itemDescription
    }
    
    var formattedPrice: String {
        let currencyLabel: String = "$"
        
        //"%@%.2f ", [replace with var name],
        return String.localizedStringWithFormat("%@%.0f", currencyLabel, price)
    }
    
    var formattedPriceWithoutSymbol: String {
    
        return String.localizedStringWithFormat("%.0f", price)
    }
    
    var isOpen: Bool
    
    
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
        self.pickupDescription = ""
        
        self.canAcceptCreditCard = false
        self.canShip = false
        
        self.isOpen = true
    }
    

    init(id: String, author: String, title: String, price: Double, itemDescription: String, createdDate: NSDate, pickupLatitude: Double, pickupLongitude: Double, pickupDescription: String, isOpen: Bool) {
        
        self.id = id
        self.author = author
        self.title = title
        self.price = price
        self.itemDescription = itemDescription
        self.createdDate = createdDate
        
        self.pickupLatitude = pickupLatitude
        self.pickupLongitude = pickupLongitude
        self.pickupDescription = pickupDescription
        
        self.canAcceptCreditCard = false
        self.canShip = false
        
        self.isOpen = isOpen
    }
    
//    init(snapshot: FIRDataSnapshot) {
//        
//        let snapshotValue = snapshot.value as! NSDictionary
//        let key = snapshot.key
//        
//        id = key
//        author = snapshotValue["author"] as! String
//        title = snapshotValue["title"] as! String
//        imageURL = snapshotValue["image_url"] as! String
//        price = snapshotValue["price"] as! Double
//        itemDescription = snapshotValue["description"] as! String
//        //createdDate = snapshotValue["created_at"] as? NSTimeInterval
//        
//        pickupLatitude = snapshotValue["pickup_latitude"] as! Double
//        pickupLongitude = snapshotValue["pickup_longitude"] as! Double
//        canAcceptCreditCard = snapshotValue["can_accept_credit"] as! Bool
//        canShip = snapshotValue["can_ship"] as! Bool
//        
//        
//        
//        let ref = snapshot.ref
//        
//    }
    
}
