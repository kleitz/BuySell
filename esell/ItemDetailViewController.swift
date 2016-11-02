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

class ItemDetailViewController: UIViewController, UIViewControllerTransitioningDelegate  {
    
    
    @IBOutlet weak var makeOfferButton: UIButton!

    
    @IBOutlet weak var containerView: UIView!
    
    var post = ItemListing(id: "temp")
    var image = UIImage()
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
 
        self.tabBarController?.setTabBarVisible(false, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeOfferButton.layer.cornerRadius = 10
        
        // Navigation UI stuff
        self.navigationItem.title = "Item Detail"
        
        
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if let identifer = segue.identifier {
            
            switch identifer {
            case "segueToCheckout":
                print(" >> prepare SEGUE to CheckoutView")
                
                guard let nextController = segue.destinationViewController as? CheckoutViewController else {
                    
                    print("segue failed")
                    return
                }
                
                nextController.post = self.post
                nextController.postImage = self.image
                
                print("  >> POST ID being sent: \(self.post.id ?? "") andt hte price is \(self.post.price). the date is \(self.post.createdDate)")
                
            case "itemDetailEmbedSegue":
                
                guard let embeddedController = segue.destinationViewController as? ItemDetailTableViewController else {
                    
                    print("segue failed")
                    return
                }
                embeddedController.postImage = self.image
                embeddedController.post = self.post
                
                
            default: break
            }
            
            
            
        }
    }
    
    
    
    deinit {
        
        print("(deinit) -> [ItemDetailViewController]")
    }
    
}





