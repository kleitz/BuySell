//
//  Bid.swift
//  esell
//
//  Created by Angela Lin on 10/15/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import Foundation


class BidForItem: NSObject {
    var bidID: String
    var parentPostID: String
    var bidderID: String
    var amount: Double
    var date: NSDate
    var isAcceptedBySeller: Bool
    var isPaidOnline: Bool
    
    init(bidID: String, parentPostID: String, bidderID: String, amount: Double, date: NSDate){
        
        self.bidID = bidID
        self.parentPostID = parentPostID
        self.bidderID = bidderID
        self.amount = amount
        
        self.date = date
        
        self.isAcceptedBySeller = false
        self.isPaidOnline = false
    }
    
    
//    var parentPost: ItemListing {
//        return ItemListing(i
//    }
    
}