//
//  FirebaseManager.swift
//  esell
//
//  Created by Angela Lin on 10/11/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//


// NOTE: The Firebase MODEL Should go here.

import Foundation
import Firebase



class FirebaseManager {
    
    weak var delegate: FirebaseManagerDelegate?
    
    // MARK: functions
    
    func fetchPosts() {
        
        print("\n > running fetchPosts()...")
        
        let ref = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com/")
        
        // you can use queryLimitedToFirst(3) to limit to max number of results returned
        
        // TODO how to order by reverse created_at ? it doesn't work.... tried queryOrderedByChild("created_at")
        // TODO could use .insert(post, atIndex: 0) if you wanted reverse order locally but it's not perfect, still better to find a way to query it from Firebase in reverse order of date
        
        ref.child("posts").queryOrderedByChild("created_at").observeEventType(.ChildAdded, withBlock: { (snapshot
            ) in
            
            print(snapshot)
            
            
            guard let dataSnapshot = snapshot.value as? [String:AnyObject] else {
                print("error unwrapping post")
                fatalError()
            }
            
            // Parse each snapshot dictionary & return as an Itemlisting class type
            
            let post = self.parseDictionarySnapshot(data: dataSnapshot)
            
            
            // Return each post gotten to the delegate in view controller
            
            self.delegate?.returnData(self, data: post)

            
            
            // Return error if error to delegate in view controller

            }, withCancelBlock: { (error) in
                print("fetchPosts error: \(error.localizedDescription)")
                self.delegate?.returnError(self, error: error)
        })

    }
    
    func parseDictionarySnapshot(data dictionary: [String:AnyObject]) -> ItemListing {
        
        let post = ItemListing()
        
        // parse all the data and store in Post class
        
        post.title = dictionary["title"] as? String
        post.itemDescription = dictionary["description"] as? String
        post.price = dictionary["price"] as? String
        post.author = dictionary["author"] as? String
        post.imageURL = dictionary["image_url"] as? String
        post.pickupLatitude = dictionary["latitude"] as? Double
        post.pickupLongitude = dictionary["longitude"] as? Double
        
        //TODO add the online payment stuff here. and shipping.
        
        
        // test print the date ...
        guard let postDate = dictionary["created_at"] as? NSTimeInterval else {
            fatalError("error getting time out")
        }
        
        // Date conversion.. need to convert the NSTimeInterval and use timeIntervalSince1970 (do Not use timeIntervalSinceReferenceDate)
        
        post.createdDate = NSDate(timeIntervalSince1970: postDate/1000)
        print("postDate -> \(post.createdDate)")
        
        
        return post
    }

}