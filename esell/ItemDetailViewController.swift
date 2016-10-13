//
//  ItemDetailViewController.swift
//  esell
//
//  Created by Angela Lin on 9/30/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import Firebase

// Note: the things needed to display here are:
// title, image, description, price

class ItemDetailViewController: UIViewController, UIViewControllerTransitioningDelegate  {
    
   
    @IBOutlet weak var itemTitle: UILabel!
    
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var itemDescription: UILabel!
    
    @IBOutlet weak var itemPrice: UILabel!
    
    @IBOutlet weak var itemSeller: UILabel!
    
    @IBOutlet weak var sellerInfoButton: UIButton!
    
    
    @IBAction func unwindToDetail(segue: UIStoryboardSegue) {}
    
    
    var post = ItemListing()
    var image = UIImage()
    
    var sellerInfo = User()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("title test print: \(post.title)")
        
        // set up the UI elements with ItemListing attributes passed in

        // OPTIONALS UNWRAP FOR ITEM INFO > make sure none of the post attributes are OPtional
        
        if let title = post.title {
            itemTitle.text = title
        }
        
        if let price = post.price {
            itemPrice.text = price
        }
        
        if let description = post.itemDescription {
            itemDescription.text = description
        }
        
        itemImage.image = image
        itemImage.contentMode = .ScaleAspectFit
        
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        //
        //            if let unwrappedImageURL: String = self.post.imageURL,
        //                let url = NSURL(string: unwrappedImageURL),
        //                let imageData = NSData(contentsOfURL: url) {
        //
        //                dispatch_async(dispatch_get_main_queue(), {
        //                    self.itemImage.image = UIImage(data: imageData)
        //                    self.itemImage.contentMode = .ScaleAspectFit
        //                })
        //            }
        //        }
        
        
        // Remember post.author == UID which should not be shown on the UI, so need to look up user from the UID
        
        guard let seller = post.author else {
            
            print("Error getting seller")
            return
        }

        // Attach function for click seller info button
        sellerInfoButton.addTarget(self, action: #selector(showSellerInfo), forControlEvents: .TouchUpInside)
        
        
        // Handle date
        
        guard let postDate = self.post.createdDate else {
            print("error")
            return
        }
        //let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let now: NSDate = NSDate()
        
        var daysAgo = "less than 1 day"
        
        switch now.daysFrom(postDate) {
        case 0: daysAgo = "today"
        case 1: daysAgo = "1 day ago"
        default: daysAgo = String("\(now.daysFrom(postDate)) days ago")
        }
        

        
        print("the current date (NSDate()) is : \(now)")
        
      
        
        // Query Firebase to get SELLER INFO to appear, use author UID to get name
        let fireBase = FirebaseManager()
        
        fireBase.fetchUserInfoFromFirebase(sellerUID: seller) { (getUser) -> (Void) in
            self.sellerInfo = getUser
            
            // USE MAIN QUEUE for UI updates
            
            dispatch_async(dispatch_get_main_queue(), {
                
                // Get picture for UI, may be optional
                
                self.itemSeller.text = ("Posted \(daysAgo) by \(self.sellerInfo.name ?? "")")
                
                
            })
            
            
            print("TESTPRINT seller displaytext.  \(self.itemSeller.text)")
            
            print("TESTPRINT Seller Info. name: \(self.sellerInfo.name!) email: \(self.sellerInfo.email)")

        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segueToCheckout" {
            print("---- segue identifer is correct")
            guard let nextController = segue.destinationViewController as? CreditCardTableViewController else {
                
                print("segue failed")
                return
            }
            
            nextController.post = self.post
            print("TEST PRINT POST ID being sent: \(self.post.id)")
        }
        
    }
    

    
    func showSellerInfo() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popupViewController = storyboard.instantiateViewControllerWithIdentifier("SellerInfoViewController") as! SellerInfoViewController
        
        popupViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        popupViewController.transitioningDelegate = self
        
        //red: 67.0/255.0, green: 86.0/255.0, blue: 97.0/255.0,
        popupViewController.view.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.9)
        //pvc.view.alpha = 0.75
            
        self.presentViewController(popupViewController, animated: true, completion: nil)
        

        
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        //presented.sellerInfo = self.sellerInfo
        //
        return HalfSizePresentationController(presentedViewController: presented, presentingViewController: presenting)
        
    }
    
    deinit {
        
        print("(deinit) -> [ItemDetailViewController]")
    }
    
}

class HalfSizePresentationController : UIPresentationController {
    override func frameOfPresentedViewInContainerView() -> CGRect {
        
        // note: used ! here
        return CGRect(x: 0, y: containerView!.bounds.height/2, width: containerView!.bounds.width, height: containerView!.bounds.height/2)
    }
}


extension NSDate {
    func yearsFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date: NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date: NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date: NSDate) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}
