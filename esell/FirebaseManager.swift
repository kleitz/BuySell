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
    
    weak var delegateForBid: FirebaseManagerBidDelegate?
    
    // MARK: functions
    
    let ref = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com/")
    
    
    func fetchPosts() {
        
        print(" > running fetchPosts()...")
        
        
        // you can use queryLimitedToFirst(3) to limit to max number of results returned
        
        // TODO how to order by reverse created_at ? it doesn't work.... tried queryOrderedByChild("created_at")
        // TODO could use .insert(post, atIndex: 0) if you wanted reverse order locally but it's not perfect, still better to find a way to query it from Firebase in reverse order of date
        
        ref.child("posts").queryOrderedByChild("created_at").observeEventType(.ChildAdded, withBlock: { (snapshot
            ) in
            
            print(snapshot)
            
            // This is the key or UID for each "post"
            let snapshotID = snapshot.key
            
            // This is the childvalues for each "post"
            guard let dataSnapshot = snapshot.value as? [String:AnyObject] else {
                print("error unwrapping post")
                fatalError()
            }
            
            // Parse each snapshot dictionary & return as an Itemlisting class type
            
            let post = self.parseDictionarySnapshot(postID: snapshotID, data: dataSnapshot)
            
            
            // Return each post gotten to the delegate in view controller
            
            self.delegate?.returnData(self, data: post)

            
            
            // Return error if error to delegate in view controller

            }, withCancelBlock: { (error) in
                print("fetchPosts error: \(error.localizedDescription)")
                self.delegate?.returnError(self, error: error)
        })

    }
    
    func parseDictionarySnapshot(postID postID: String, data dictionary: [String:AnyObject]) -> ItemListing {
        
        let post = ItemListing()
        
        // parse all the data and store in Post class
        post.id = postID
        post.title = dictionary["title"] as? String
        post.itemDescription = dictionary["description"] as? String
        post.price = dictionary["price"] as? String
        post.author = dictionary["author"] as? String
        post.imageURL = dictionary["image_url"] as? String
        post.pickupLatitude = dictionary["pickup_latitude"] as? Double
        post.pickupLongitude = dictionary["pickup_longitude"] as? Double
        post.canAcceptCreditCard = dictionary["can_accept_credit"] as? Bool ?? false
        post.canShip = dictionary["can_ship"] as? Bool ?? false
        
        //TODO add the online payment stuff here. and shipping.
        
        
        // test print the date ...
        guard let postDate = dictionary["created_at"] as? NSTimeInterval else {
            fatalError("error getting time out")
        }
        
        // Date conversion.. need to convert the NSTimeInterval and use timeIntervalSince1970 (do Not use timeIntervalSinceReferenceDate)
        
        post.createdDate = NSDate(timeIntervalSince1970: postDate/1000)
        print("postDate converted: \(post.createdDate)")
        
        
        return post
    }
    
    
    // Find a specific seller by UID
    
    func fetchUserInfoFromFirebase(sellerUID uid: String, withCompletionHandler: (getUser: User)-> Void ) {
        
        ref.child("users").queryOrderedByKey().queryEqualToValue(uid).observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else {
                print("[QUERY] Error: failed getting all users call in database")
                return
            }
            
            print("test print full dictionary w/ toplevel ID: \(dictionary)")
            
            
            guard let sellerData = dictionary[uid] as? [String: AnyObject] else {
                print("[QUERY] Error: failed getting seller key's values")
                return
            }
            
            
            // Prep the User object to return
            let sellerInfo = User()
            
            
            if let imageURL = sellerData["fb_pic_url"] as? String {
                sellerInfo.imageURL = imageURL
            }
            
            
            // Get the name & email
            
            guard let name = sellerData["name"] as? String,
                let email = sellerData["email"] as? String else {
                    print("error")
                    return
            }
            sellerInfo.name = name
            sellerInfo.email = email
   
            print("sellerData dict value: \(sellerData)")
    
            withCompletionHandler(getUser: sellerInfo)
        })
        
    }

    
    
    func saveBid(parentPostID postID: String, bidAmount: Double, creditCardInfo: CreditCard) {
        
        let bidsRef = ref.child("bids")
        
        //let refUnderCurrentPost = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com").child("posts")
        
        let newBidItem = bidsRef.childByAutoId()
        
        
        // Get the userID from userdefaults to save as "author" key
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard let userID = defaults.stringForKey("uid") else {
            print("failed getting nsuserdefaults uid")
            return
        }

        let values = [ "parent_post_id": postID,
                       "amount": bidAmount,
                       "created_at": FIRServerValue.timestamp(),
                       "bid_accepted": "false",
                       "cc_name_on_card": creditCardInfo.nameOnCard,
                       "cc_number": creditCardInfo.cardNumber,
                       "cc_exp_month": creditCardInfo.expiryMonth,
                       "cc_exp_year": creditCardInfo.expiryYear,
                       "bidder_id": userID ]
        
        newBidItem.updateChildValues(values as [NSObject : AnyObject], withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err?.localizedDescription)
                return
            }
            
            //TODO anoterh delegate to let kCController know it's done saving??
            self.delegateForBid?.bidComplete(self, didComplete: true)
            
            print("saved BID info successfly in firebase DB")
        })
    }

    
    
}