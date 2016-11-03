//
//  ItemDetailViewController.swift
//  esell
//
//  Created by Angela Lin on 9/30/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit


// Note: the things needed to display here are:
// title, image, description, price

class ItemDetailViewController: UIViewController, UIViewControllerTransitioningDelegate, ItemDetailDelegate  {
    
    
    @IBOutlet weak var makeOfferButton: UIButton!

    
    @IBOutlet weak var containerView: UIView!
    
    var post = ItemListing(id: "temp")
    var image = UIImage()
    
    // vars for Seller
    
    var sellerAsUser = User(id: "temp")
    var sellerImage = UIImage()
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
 
        self.tabBarController?.setTabBarVisible(false, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeOfferButton.layer.cornerRadius = 10
        
        // Navigation UI stuff
        self.navigationItem.title = "Item Detail"
        
        
        //// TO DO GET HE SLELER INFO HERE AND pass on into embed segue. rather than doing the seller info inside th embedded vc's logic
        
        // Query Firebase to get SELLER INFO to appear, use author UID to get name
        let fireBase = FirebaseManager()
        
        fireBase.lookupSingleUser(userID: post.author) { (getUser) -> (Void) in
            
            self.sellerAsUser = getUser
            
            self.loadSellerInfo(self.sellerAsUser)
        }
        
        
    }
    
    func buttonWasClicked(manager: ItemDetailTableViewController, didClick: Bool) {
        
        if didClick {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextController = storyboard.instantiateViewControllerWithIdentifier("SellerInfoViewController") as! SellerInfoViewController
        
            
            nextController.userInfo = self.sellerAsUser
            nextController.userImage = self.sellerImage
        
            
            self.showViewController(nextController, sender: self)
            
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if let identifer = segue.identifier {
            
            switch identifer {
                
            case "itemDetailEmbedSegue":
                
                guard let embeddedController = segue.destinationViewController as? ItemDetailTableViewController else {
                    
                    print("segue failed")
                    return
                }
                embeddedController.postImage = self.image
                embeddedController.post = self.post
                
                embeddedController.delegate = self
                
            case "segueToCheckout":
                print(" >> prepare SEGUE to CheckoutView")
                
                guard let nextController = segue.destinationViewController as? CheckoutViewController else {
                    
                    print("segue failed")
                    return
                }
                
                nextController.post = self.post
                nextController.postImage = self.image
                
                print("  >> POST ID being sent: \(self.post.id ?? "") andt hte price is \(self.post.price). the date is \(self.post.createdDate)")
        
                
            default: break
            }
        }
    }
    
    
    func loadSellerInfo(sellerData: User) {
        
        // Background for get profile image
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            // Jump in to a background thread to get the image for this item
            
            if let url = NSURL(string: sellerData.imageURL) {
                
                // Download an NSData representation of the image at the URL
                let urlRequest = NSURLRequest(URL: url)
                
                let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
                    if error == nil {
                        
                        guard let unwrappedData = data else {
                            print("Error converting image")
                            return
                        }
                        
                        guard let image = UIImage(data: unwrappedData) else {
                            print("Error converting image")
                            return
                        }
                        
                        
                        self.sellerImage = image
                        
                    } else {
                        
                        print(error?.localizedDescription)
                    }
                })
                
                task.resume()
            }
        }

    }
    
    deinit {
        
        print("(deinit) -> [ItemDetailViewController]")
    }
    
}





