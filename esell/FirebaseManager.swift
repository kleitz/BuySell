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
    
    
    let ref = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com/")
    
    
    // MARK: Functions for write Data to Firebase
    
    // save user in database
    
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
    
    
    // save bid in database
    
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
                       "bid_responded": false,
                       "bid_accepted": false,
                       //                       "cc_name_on_card": creditCardInfo.nameOnCard,
            //                       "cc_number": creditCardInfo.cardNumber,
            //                       "cc_exp_month": creditCardInfo.expiryMonth,
            //                       "cc_exp_year": creditCardInfo.expiryYear,
            "has_paid_online": hasPaidOnline,
            "bidder_id": userID ]
        
        newBidItem.updateChildValues(values as [NSObject : AnyObject], withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err?.localizedDescription)
                self.delegateForBid?.bidComplete(self, didComplete: false)
                return
            }
            
            //TODO anoterh delegate to let kCController know it's done saving??
            self.delegateForBid?.bidComplete(self, didComplete: true)
            
            print("saved BID info successfly in firebase DB")
        })
    }
    

    // MARK: Functions for UPDATING Data (overwrite) 
    
    func updateAllBidsOfOnePost(parentPostID parentPostID: String, acceptedBidID: String, withCompletionHandler: (isUpdated: Bool ) -> Void) {
        
        // before this, both bid_accepted and bid_responded should be 'false'
        
        
        
        // set all other ones as rejected???
        // loop for query of all bids under parent_post_id
        
        self.fetchBidsByParentPost(postID: parentPostID) { (bidsArrayForOnePost) in
            
            print("[updateAllBids...] total bids in array: \(bidsArrayForOnePost.count)")
            for eachBid in bidsArrayForOnePost {
                
                // add conditional so that it doesn't equal to the original
                
                // set ALL BIDS' bid_responded = true
                self.ref.child("bids/\(eachBid.bidID)/bid_responded").setValue(true)
                
                // set the ACCEPTED ONLY for bid_accepted = true,  all others = false (remains false)
                
                print("[updateAllBids...] running array: BIDID: \(eachBid.bidID) compareTO parentpost\(parentPostID)")
                if eachBid.bidID == acceptedBidID {
                    
                    self.ref.child("bids/\(acceptedBidID)/bid_accepted").setValue(true)
                    
                }
                else {
                    // uh this hsould already be false so maybe just delete this? TODO
                    self.ref.child("bids/\(eachBid.bidID)/bid_accepted").setValue(false)
                }
            }
            withCompletionHandler(isUpdated: true)
        }
    }
    
    
    
    // MARK: Functions for fetching Data
    
    func fetchPostsForBrowse() {
        
        ref.child("posts").queryOrderedByChild("created_at").observeEventType(.Value, withBlock: { (snapshot
            ) in
            
            
            
            for item in [snapshot.value] {
                print("   [fetchBidsbyPost] >> IN HASGOT VALUE >>")
                //print("TEST ITEM PRINT bid: \(item)")
                
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
                
                
                for (index,item) in firebaseItemValue.enumerate() {
                    
                    let postID = firebaseItemKey[index]
                    
                    // Parse all firebase data
                    
                    let post = self.parsePostSnapshot(postID: postID, data: item as! [String : AnyObject])
                    
                    // Return each post gotten to the delegate in view controller
                    
                    self.delegate?.returnData(self, data: post)
                }
            }
            
            // Return error if error to delegate in view controller
            
            }, withCancelBlock: { (error) in
                print("fetchPosts error: \(error.localizedDescription)")
                self.delegate?.returnError(self, error: error)
        })

        
    }
    
    func fetchPosts() {
        
        print(" > running fetchPosts()...")
        
        
        // you can use queryLimitedToFirst(3) to limit to max number of results returned
        
        // TODO how to order by reverse created_at ? it doesn't work.... tried queryOrderedByChild("created_at")
        // TODO could use .insert(post, atIndex: 0) if you wanted reverse order locally but it's not perfect, still better to find a way to query it from Firebase in reverse order of date
        
        ref.child("posts").queryOrderedByChild("created_at").observeEventType(.ChildAdded, withBlock: { (snapshot
            ) in
            
            //TESTPRINT
            //print(snapshot)
            
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
    
    
    // Grab the original 1 post from the parent_post_id (PostID) in Bid Info. Lookup return value in "posts".
    
    func lookupSinglePost(postID postID: String, withCompletionHandler: (returnedPost: ItemListing)-> Void) {
        
        var post = ItemListing(id: postID)
        
        ref.child("posts").queryOrderedByKey().queryEqualToValue(postID).observeSingleEventOfType(.ChildAdded, withBlock:  { (snapshot) in
            
            //            print("[singlePostByID] KEY-> \(snapshot.key)")
            //            print("[singlePostByID] VAL -> \(snapshot.value)\n")
            
            // This is the childvalues for each "post"
            guard let dataSnapshot = snapshot.value as? [String:AnyObject] else {
                print("error unwrapping post")
                fatalError()
            }
            
            post = self.parsePostSnapshot(postID: postID, data: dataSnapshot)
            
            
            withCompletionHandler(returnedPost: post)
        })
        
    }
    
    // Fetch all user info by UID (like to get seller info from a bid's post owner)
    
    func lookupSingleUser(userID uid: String, withCompletionHandler: (getUser: User)-> Void ) {
        
        ref.child("users").queryOrderedByKey().queryEqualToValue(uid).observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            
            print("[fetchUserInfoFromFirebase]  snapshot: \(snapshot)")
            guard let dictionary = snapshot.value as? [String:AnyObject] else {
                print("[fetchUserInfoFromFirebase] Error: failed getting user in database")
                return
            }
            
            // print("test print full dictionary w/ toplevel ID: \(dictionary)")
            
            
            guard let sellerData = dictionary[uid] as? [String: AnyObject] else {
                print("[fetchUserInfoFromFirebase] Error: failed getting seller key's values")
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
            
            
            print("[fetchUserInfoFromFirebase] userData dict value: \(sellerData)")
            
            withCompletionHandler(getUser: sellerInfo)
        })
        
    }

    
    // This function is used to grab ALL BIDS from the parent_post_id in Bid Info. Lookup return value in "bids".
    
    func fetchBidsByParentPost(postID postID: String, withCompletionHandler: (bidsArrayForOnePost: [BidForItem]) -> Void) {
        
        // note: limit to 25
        
        print("   [fetchBidsbyPost]  ->> look up this post id: \(postID)")
        
        // TODO can use regular event here? or use SINGLE is better? I don't see it refresh when someone bids for the item even when I use eregular eventType, not single eventType
        
        ref.child("bids").queryOrderedByChild("parent_post_id").queryEqualToValue(postID).queryLimitedToLast(25).observeEventType(.Value, withBlock: { (snapshot
            ) in
            
            // This will loop through each query (snapshot)
            
            print("   [fetchBidsbyPost] snapshot exists?= \(snapshot.exists())")
            
            if snapshot.exists() != false {
                
                // This means: for each item in the array (snapshot.value is an array with a list of values), go through each arrayItem
                
                for item in [snapshot.value] {
                    print("   [fetchBidsbyPost] >> IN HASGOT VALUE >>")
                    //print("TEST ITEM PRINT bid: \(item)")
                    
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
                    
                    var bidArray = [BidForItem]()
                    
                    for (index,item) in firebaseItemValue.enumerate() {
                        
                        let bidID = firebaseItemKey[index]
                        
                        // Parse all firebase data
                        
                        let bid = self.parseBidSnapshot(bidID: bidID, data: item as! [String : AnyObject])
                        
                        // Append to the array of posts to be returned from function
                        bidArray.append(bid)
                    }
                    
                    withCompletionHandler(bidsArrayForOnePost: bidArray)
                }
                
            } else {
                print("   [fetchBidsbyPost] >> IN THE ELSE >>")
                var bidArray = [BidForItem]()
                bidArray.append(BidForItem(bidID: "placeholder"))
                
                withCompletionHandler(bidsArrayForOnePost: bidArray)
            }
            
            }, withCancelBlock: { (error) in
                print("fetchBIDS error: \(error.localizedDescription)")
                
        })

    }
    
    
    // Grab ALL POSTS from a UserID. Lookup return value in "posts".
    
    func fetchPostsByUserID(userID uid: String, withCompletionHandler: (postsCreated: [ItemListing])-> Void) {
        
        print(">>> RUnning query for POSTS created by user.")
        
        // note: limit to 25
        
        ref.child("posts").queryOrderedByChild("author").queryEqualToValue(uid).queryLimitedToLast(25).observeEventType(.Value, withBlock: { (snapshot
            ) in
            
            
            print("   [fetchPostsByUserID] snapshot exists?= \(snapshot.exists())")
            
            if snapshot.exists() != false {
                
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
            } else {
                var postArray = [ItemListing]()
                
                postArray.append(ItemListing(id: "placeholder"))
                withCompletionHandler(postsCreated: postArray)
            }
            
            
        })
    }
    
    

    
    // Grab ALL bids by a UID
    
    func fetchBidsByUserID(userID uid: String, withCompletionHandler: (bidsCreated: [BidForItem])-> Void ){
        // wront way of writing query
        // ref.child("bids").queryEqualToValue(uid).observeSingleEventOfType(.Value)
        
        // correct way
        
        // note: limit to 25
        
        ref.child("bids").queryOrderedByChild("bidder_id").queryEqualToValue(uid).queryLimitedToLast(25).observeEventType(.Value, withBlock: { (snapshot
            ) in
            if snapshot.exists() != false {
            
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
                
                
                var bidArray = [BidForItem]()
                
                for (index,item) in firebaseItemValue.enumerate() {
                    
                    let bidID = firebaseItemKey[index]
                    
                    // Parse all firebase data
                    
                    let bid = self.parseBidSnapshot(bidID: bidID, data: item as! [String : AnyObject])
                    
                    // Append to the array of posts to be returned from function
                    print("Bid to append: (example info: \(bid.date), \(bid.amount) \(bid.bidderID)")
                    
                    bidArray.append(bid)
                    
                    
                }
                // Return data
 
                withCompletionHandler(bidsCreated: bidArray)
                
            }
            }
            }, withCancelBlock: { (error) in
                print("fetchBIDS error: \(error.localizedDescription)")
                
                
                // TODO
        })
        
    }

    
    
    // MARK: Functions for parsing snapshots
    
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

        //print("> test print parsePOSTsnapshot. postDate: \(post.createdDate)")
        
        //print("> test print. post PARSED result: price: \(post.price) || lat: \(post.pickupLatitude) & lon:\(post.pickupLongitude)")
        
        return post
    }
    
    
    func parseBidSnapshot(bidID bidID: String, data dictionary: [String:AnyObject]) -> BidForItem {
        
        // Parse all core firebase data
        
        guard let bidderID = dictionary["bidder_id"] as? String,
            let parentPostID = dictionary["parent_post_id"] as? String,
            let amount = dictionary["amount"] as? Double,
            let isRespondedBySeller = dictionary["bid_responded"] as? Bool,
            let isAcceptedBySeller = dictionary["bid_accepted"] as? Bool,
            let isPaidOnline = dictionary["has_paid_online"] as? Bool else {
                fatalError("Error parsing")
        }
        
        // Convert date from NSTimeInterval (from json) into readable NSDate
        
        guard let postRawDate = dictionary["created_at"] as? NSTimeInterval else {
            fatalError("Error getting time out")
        }
        let postDate = self.convertNSTimeIntervaltoNSDate(date: postRawDate)
        
        
        // Create new bid to store all this.
        
        let bid = BidForItem(bidID: bidID, parentPostID: parentPostID, bidderID: bidderID, amount: amount, date: postDate)

        bid.isAcceptedBySeller = isAcceptedBySeller
        bid.isRespondedBySeller = isRespondedBySeller
        bid.isPaidOnline = isPaidOnline
        
        print(">> insidePARSEBID FUNCTIOn ~~ isPaidOnline, isAcceptedBySeller==> \(isPaidOnline), \(isAcceptedBySeller)")
        
        //print("> test print. post PARSED result: price: \(post.price) || lat: \(post.pickupLatitude) & lon:\(post.pickupLongitude)")
        
        return bid
    }
    
    
    
    
    
    
    
    // MARK: Funciton other: convert time
    
    private func convertNSTimeIntervaltoNSDate(date date: NSTimeInterval) -> NSDate {
    
        return NSDate(timeIntervalSince1970: date/1000)
        
    }
    
    
}