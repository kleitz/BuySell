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
    var isRespondedBySeller: Bool
    
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
        self.isRespondedBySeller = false
    }
    
    init(bidID: String, parentPostID: String, bidderID: String, amount: Double, date: NSDate, isAccepted: Bool, isPaidOnline: Bool){
        
        self.bidID = bidID
        self.parentPostID = parentPostID
        self.bidderID = bidderID
        self.amount = amount
        
        self.date = date
        
        self.isAcceptedBySeller = isAccepted
        self.isPaidOnline = isPaidOnline
        self.isRespondedBySeller = false
    }
    
    
    init(bidID: String){
        
        self.bidID = bidID
        self.parentPostID = ""
        self.bidderID = ""
        self.amount = 0
        self.date = NSDate()
        self.isAcceptedBySeller = false
        self.isPaidOnline = false
        self.isRespondedBySeller = false
    }
    
    // Add these stored type Vars -  easier get data out like sller name, image, etc
    
    var parentPostInfo: ItemListing? { didSet { print("       -> bid got post.Info")} }
    
    var parentPostUserInfo: User?   { didSet { print("       -> bid got user.Info")} }
    
}