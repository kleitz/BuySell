//
//  PlaceBidViewController.swift
//  esell
//
//  Created by Angela Lin on 10/13/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

protocol FirebaseManagerBidDelegate: class {
    
    func bidComplete(manager: FirebaseManager, didComplete: Bool)
    
}


class CheckoutViewController: UIViewController, FirebaseManagerBidDelegate  {

    // MARK: - IBOutlets
    

    @IBOutlet weak var mainContainerView: UIView!
    
    @IBOutlet weak var checkoutButton: UIButton!
    
    
    
    // MARK: - Data Variables
    
    var post = ItemListing(id: "test")
    var postImage = UIImage()
    
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        print("post received??? in CheckoutViewController \(post.id) & price: \(post.price)")
        
        // Add function to button
        checkoutButton.layer.cornerRadius = 10
        checkoutButton.addTarget(self, action: #selector(prepareSaveOffer), forControlEvents: .TouchUpInside)
        
        
        // Add the TableViewController into the viewcontroller
        
        let storyboard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
        
        let childViewController = storyboard.instantiateViewControllerWithIdentifier("CheckoutTableViewController") as! CheckoutTableViewController
        
        // Add child view controller
        self.addChildViewController(childViewController)
        
        // Add child view as subview [of parent]
        self.mainContainerView.addSubview(childViewController.view)
        
        // Configure child view
        childViewController.view.frame = self.mainContainerView.bounds
        childViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Notify the child view controller
        childViewController.didMoveToParentViewController(self)
        
    }



    
    // MARK: - FUNCTIONS
    
    func prepareSaveOffer() {
        
        // guard for non nil values
        guard let childViewController = self.childViewControllers.first as? CheckoutTableViewController else {
            fatalError()
            //TODO change to return later
        }
        
        let postID = childViewController.post.id
        let price = childViewController.post.price

        if isStringNumerical(childViewController.offerAmount.text) == false || childViewController.offerAmount.text == "" || childViewController.offerAmount.text == "0" {
            
            popupNotifyIncomplete("You must enter a valid offer amount")
        }
        
        // Pass to Firebase
        
        let fireBase = FirebaseManager()
        
        fireBase.delegateForBid = self
        
        
        // Save the bid to firebase. Removed credit card info as the parameter because shouldn't actually store it - just store the payment method (cash or credit), not the actual card info
        
        fireBase.saveBid(parentPostID: postID, bidAmount: price, hasPaidOnline: false)
        
    }
    
    func bidComplete(manager: FirebaseManager, didComplete: Bool) {
        if didComplete == true {
            popupNotifyPosted(title: "Bid Completed", message: "Your bid has been sent!")
        } else {
            popupNotifyPosted(title: "Error sending bid", message: "Please try again, something went wrong")
        }
    }
    
    
    func isStringNumerical(string : String) -> Bool {
        // Only allow numbers. Look for anything not a number.
        let range = string.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        return (range == nil)
    }
    
    
    
    
    // Popup alert if missing fields
    
    func popupNotifyIncomplete(errorMessage: String){
        
        let alertController = UIAlertController(title: "Wait!", message:
            errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { action in
            print("test: pressed Dismiss")
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
    // Popup alert if Post Successful
    
    func popupNotifyPosted(title title: String, message: String){
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { action in
            
            // when click OK on alert, unwind back to previous view
            self.performSegueWithIdentifier("unwindToDetail", sender: self) })
        )
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func roundUIView(view: UIView, cornerRadiusParams: CGFloat!) {
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadiusParams
    }



}
