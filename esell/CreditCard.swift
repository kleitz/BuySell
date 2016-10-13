//
//  CreditCard.swift
//  esell
//
//  Created by Angela Lin on 10/13/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import Foundation

class CreditCard: NSObject {
    
    var nameOnCard: String
    
    var cardNumber: String
    
    var expiryMonth: String
    
    var expiryYear: String

    init(nameOnCard: String, cardNumber: String, expiryMonth: String, expiryYear: String) {
        
        self.nameOnCard = nameOnCard
        self.cardNumber = cardNumber
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
    }
    
}