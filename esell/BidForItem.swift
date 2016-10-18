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
    
    var formattedAmount: String {
        let currencyLabel: String = "$ "
        
        //"%@%.2f ", [replace with var name],
        return String.localizedStringWithFormat("%@%.0f", currencyLabel, amount)
    }
    
    init(bidID: String, parentPostID: String, bidderID: String, amount: Double, date: NSDate){
        
        self.bidID = bidID
        self.parentPostID = parentPostID
        self.bidderID = bidderID
        self.amount = amount
        
        self.date = date
        
        self.isAcceptedBySeller = false
        self.isPaidOnline = false
    }
    
    init(bidID: String){
        
        self.bidID = bidID
        self.parentPostID = ""
        self.bidderID = ""
        self.amount = 0
        self.date = NSDate()
        self.isAcceptedBySeller = false
        self.isPaidOnline = false
    }
    
    ///TODO add bidder name for this. otherwise how to get the name on UI???
    
//    var parentPost: ItemListing {
//        return ItemListing(i
//    }
    
}