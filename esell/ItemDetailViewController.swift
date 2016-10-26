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
    
    
    @IBAction func unwindToDetail(segue: UIStoryboardSegue) {}
    
    @IBOutlet weak var containerView: UIView!
    
    var post = ItemListing(id: "temp")
    var image = UIImage()
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        print(self.tabBarController?.tabBar.hidden)
        
        self.tabBarController?.setTabBarVisible(false, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Navigation UI stuff
        self.navigationItem.title = "Item Detail"
        
        
//        // Add the other tableviewcontroller as subview into the containerView
//        
//        let storyboard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
//        
//        let itemDetailView = storyboard.instantiateViewControllerWithIdentifier("ItemDetailTableViewController") as! ItemDetailTableViewController
//        
//        // Add child view controller
//        self.addChildViewController(itemDetailView)
//        
//        // Add child view as subview [of parent]
//        self.containerView.addSubview(itemDetailView.view)
//        
//        // Configure child view
//        itemDetailView.view.frame = self.containerView.bounds
//        itemDetailView.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//        
//        // Notify the child view controller
//        itemDetailView.didMoveToParentViewController(self)
        
        
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





