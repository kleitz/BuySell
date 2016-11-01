//
//  User.swift
//  esell
//
//  Created by Angela Lin on 9/28/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import Foundation

class User: NSObject {
    
    var id: String
    var name: String
    var email: String
    var imageURL: String
    var createdDate: NSDate
    var profileURL: String
    
//    var location: String?
//    
//    var phone: String?

    init(id: String, name: String, email: String, imageURL: String, profileURL: String) {
        self.id = id
        self.name = name
        self.email = email
        self.imageURL = imageURL
        self.createdDate = NSDate()
        self.profileURL = profileURL
    }
    
    init(id: String) {
        self.id = id
        self.name = ""
        self.email = ""
        self.imageURL = ""
        self.createdDate = NSDate()
        self.profileURL = ""
    }
    
}