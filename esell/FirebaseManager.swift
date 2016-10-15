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
    
    
    func createNewUserInFirebase(uid: String, name: String, email: String, createdAt: NSObject, fbID: String, fbPicURL: String, fbURL: String ) {
        
        let usersRef = ref.child("users").child(uid)
        
        let values: [NSObject:AnyObject] = ["name": name, "email": email, "created_at": FIRServerValue.timestamp(), "fb_id": fbID, "fb_url": fbURL , "fb_pic_url": fbPicURL]
        
        usersRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err?.localizedDescription)
                return
            }
            
            print("[LoginControl] user info -> in firebase DB")
            
        })
        
    }
    
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
            
            let post = self.parsePostSnapshot(postID: snapshotID, data: dataSnapshot)
            
            
            // Return each post gotten to the delegate in view controller
            
            self.delegate?.returnData(self, data: post)

            
            
            // Return error if error to delegate in view controller

            }, withCancelBlock: { (error) in
                print("fetchPosts error: \(error.localizedDescription)")
                self.delegate?.returnError(self, error: error)
        })

    }
    
    func parsePostSnapshot(postID postID: String, data dictionary: [String:AnyObject]) -> ItemListing {
        
        // Parse all core firebase data
        
        guard let postTitle = dictionary["title"] as? String,
            let postImageURL = dictionary["image_url"] as? String,
            let postDescription = dictionary["description"] as? String,
            let postAuthor = dictionary["author"] as? String,
            let postPrice = dictionary["price"] as? Double,
            let pickupLatitude = dictionary["pickup_latitude"] as? Double,
            let pickupLongitude = dictionary["pickup_longitude"] as? Double else {
                fatalError("Error parsing")
        }
        
        // Convert date from NSTimeInterval (from json) into readable NSDate
        
        guard let postRawDate = dictionary["created_at"] as? NSTimeInterval else {
            fatalError("Error getting time out")
        }
        let postDate = self.convertNSTimeIntervaltoNSDate(date: postRawDate)

        
        // Create new post to store all this.
        
        let post = ItemListing(id: postID, author: postAuthor, title: postTitle, price: postPrice, itemDescription: postDescription, createdDate: postDate, pickupLatitude: pickupLatitude, pickupLongitude: pickupLongitude)
        
        post.imageURL = postImageURL

        
        // Handle the temporary optional fields (TODO Fix later since firebase has inconsistent data these are optional)
        
        if
            let canAcceptCreditCard = dictionary["can_accept_credit"] as? Bool,
            let canShip = dictionary["can_ship"] as? Bool  {
                
            
                post.pickupLatitude = pickupLatitude
                post.pickupLongitude = pickupLongitude
                post.canAcceptCreditCard = canAcceptCreditCard
                post.canShip = canShip
        }

        print("> test print. postDate: \(post.createdDate)")
        
        //print("> test print. post PARSED result: price: \(post.price) || lat: \(post.pickupLatitude) & lon:\(post.pickupLongitude)")
        
        return post
    }
    
    
    ///TODO
    //func parseBidSnapshot()
    
    
    
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
            
            
            
            // Get the name & email
            
            guard let name = sellerData["name"] as? String,
                let email = sellerData["email"] as? String,
                let imageURL = sellerData["fb_pic_url"] as? String else {
                    print("error")
                    return
            }

   
            // Prep the User object to return
            
            let sellerInfo = User(id: uid, name: name, email: email, imageURL: imageURL)
            
            
            print("sellerData dict value: \(sellerData)")
    
            withCompletionHandler(getUser: sellerInfo)
        })
        
    }

    
    
    func saveBid(parentPostID postID: String, bidAmount: Double, hasPaidOnline: Bool) {
        
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
//                       "cc_name_on_card": creditCardInfo.nameOnCard,
//                       "cc_number": creditCardInfo.cardNumber,
//                       "cc_exp_month": creditCardInfo.expiryMonth,
//                       "cc_exp_year": creditCardInfo.expiryYear,
                        "has_paid_online": hasPaidOnline,
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

    
    
    func queryForPostsCreated(byUserID uid: String, withCompletionHandler: (postsCreated: [ItemListing])-> Void) {
        
        print(">>> RUnning query for posts created by user.")
        
        // note: limit to 25
        
        ref.child("posts").queryOrderedByChild("author").queryEqualToValue(uid).queryLimitedToLast(25).observeSingleEventOfType(.Value, withBlock: { (snapshot
            ) in
            
            
            // This means: for each item in the array (snapshot.value is an array with a list of values), go through each arrayItem
            
            for item in [snapshot.value] {
                
                // Create a dictinoary for each item in the array
                guard let itemDictionary = item as? NSDictionary else {
                    fatalError()
                }
                
                // get all the keys as 1 array (which would be the uid, as the 1st layer )
                guard let firebaseItemKey = itemDictionary.allKeys as? [String] else {
                    fatalError()
                }
                
                // get all the values in the array (which are in a key/value dictinoary format (the 2nd layer))
                guard let firebaseItemValue = itemDictionary.allValues as? [NSDictionary] else {
                    fatalError()
                }
                
                
                var postArray = [ItemListing]()
                
                for (index,item) in firebaseItemValue.enumerate() {
                    
                    let postID = firebaseItemKey[index]
                    
                    // Parse all firebase data
                    
                    let post = self.parsePostSnapshot(postID: postID, data: item as! [String : AnyObject])
                    
                    // Append to the array of posts to be returned from function
                    print("POST to append: \(post.title)")
                    postArray.append(post)
                }
                withCompletionHandler(postsCreated: postArray)
            }

        })
        
        
        
        
    }
    
    
    func queryForBidsCreated(byUserID uid: String){
        // wront way of writing query
        // ref.child("bids").queryEqualToValue(uid).observeSingleEventOfType(.Value)
        
        // correct way
        ref.child("bids").queryOrderedByChild("bidder_id").queryEqualToValue(uid).observeSingleEventOfType(.Value) { (snapshot
            ) in
            print(snapshot)
            
            
        }
        
    }
    
    private func convertNSTimeIntervaltoNSDate(date date: NSTimeInterval) -> NSDate {
    
        return NSDate(timeIntervalSince1970: date/1000)
        
    }
    
    
}