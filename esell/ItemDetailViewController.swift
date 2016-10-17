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
    
    @IBOutlet weak var sellerProfileImage: UIImageView!
    
    
    @IBAction func unwindToDetail(segue: UIStoryboardSegue) {}
    
    
    var post = ItemListing(id: "temp")
    var image = UIImage()
    
    var sellerAsUser = User(id: "temp")

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the UI elements with ItemListing attributes passed in

        itemTitle.text = post.title
        
        itemPrice.text = post.formattedPrice
        
        itemDescription.text = post.itemDescription
    
        print(" \n  -->: Title: \(post.title), Price: \(post.formattedPrice), Desc: \(post.itemDescription)")
        
        
        itemImage.image = image
        itemImage.contentMode = .ScaleAspectFit
     

        // Attach function for click seller info button
        sellerInfoButton.addTarget(self, action: #selector(popupSellerInfo), forControlEvents: .TouchUpInside)
        
        
        // Remember post.author == UID which should not be shown on the UI, so need to look up user from the UID
        // Query Firebase to get SELLER INFO to appear, use author UID to get name
        let fireBase = FirebaseManager()
        
        fireBase.fetchUserInfoFromFirebase(sellerUID: post.author) { (getUser) -> (Void) in
            
            self.sellerAsUser = getUser
            
            self.loadSellerInfo(self.sellerAsUser)
        }

        
        
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segueToCheckout" {
            print(" >> prepare SEGUE to CheckoutView")
            
            guard let nextController = segue.destinationViewController as? CheckoutViewController else {
                
                print("segue failed")
                return
            }
            
            nextController.post = self.post
            print("  >> POST ID being sent: \(self.post.id ?? "") andt hte price is \(self.post.price)")
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
                        
                        // Display image (using main thread
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            self.sellerProfileImage.image = image
                            self.sellerProfileImage.contentMode = .ScaleAspectFill
                            
                            self.roundUIView(self.sellerProfileImage, cornerRadiusParams: self.sellerProfileImage.frame.size.width / 2)
                            
                        })
                        
                    } else {
                        
                        print(error?.localizedDescription)
                    }
                })
                
                task.resume()
         
            }
        }
        
        
        print("(TESTPRINT) Seller byline text.  \(self.itemSeller.text)")
        
        print("(TESTPRINT) Seller Info. name: \(self.sellerAsUser.name) email: \(self.sellerAsUser.email)")
        

        // Handle date

        //let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let now: NSDate = NSDate()
        
        var daysAgo = "less than 1 day"
        
        switch now.daysFrom(self.post.createdDate) {
            
            case 0: daysAgo = "today"
            case 1: daysAgo = "1 day ago"
            
        default: daysAgo = String("\(now.daysFrom(self.post.createdDate)) days ago")
        
        }
        
        
        
        print("the current date (NSDate()) is : \(now)")
        // Display seller name as text
        
        self.itemSeller.text = ("Posted \(daysAgo) by \(self.sellerAsUser.name ?? "")")
        
        
    }

    
    func popupSellerInfo() {
        
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
    

    // for image rounding
    
    private func roundUIView(view: UIView, cornerRadiusParams: CGFloat!) {
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadiusParams
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
