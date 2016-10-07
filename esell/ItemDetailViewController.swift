//
//  ItemDetailViewController.swift
//  esell
//
//  Created by Angela Lin on 9/30/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import Firebase

class ItemDetailViewController: UIViewController, UIViewControllerTransitioningDelegate  {
    
   
    @IBOutlet weak var itemTitle: UILabel!
    
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var itemDescription: UILabel!
    
    @IBOutlet weak var itemPrice: UILabel!
    
    @IBOutlet weak var itemSeller: UILabel!
    
    @IBOutlet weak var sellerInfoButton: UIButton!
    
    
    var post = ItemListing()
    
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
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            if let unwrappedImageURL: String = self.post.imageURL,
                let url = NSURL(string: unwrappedImageURL),
                let imageData = NSData(contentsOfURL: url) {
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.itemImage.image = UIImage(data: imageData)
                    self.itemImage.contentMode = .ScaleAspectFit
                })
            }
            
        }
        
        // Remember post.author == UID which should not be shown on the UI, so need to look up user from the UID
        
        guard let seller = post.author else {
       
            fatalError("Error getting seller")
            
        }

        // Attach function for click seller info button
        sellerInfoButton.addTarget(self, action: #selector(showSellerInfo), forControlEvents: .TouchUpInside)
        
        // Query Firebase to get SELLER INFO to appear, use author UID to get name

        fetchUserInfoFromFirebase(sellerUID: seller)

        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: Functions
    
    // Find a specific seller by UID

    func fetchUserInfoFromFirebase(sellerUID uid: String){
        
        let ref = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com/").child("users")
        
        ref.queryOrderedByKey().queryEqualToValue(uid).observeSingleEventOfType(.Value, withBlock:  { (snapshot) in

            guard let dictionary = snapshot.value as? [String:AnyObject] else {
                
                print("Error: failed getting top level keyID dict out of user query")
                return
            }
            print("test print full dictionary w/ toplevel ID: \(dictionary)")
            
            
            guard let childDictionary = dictionary[uid] as? [String: AnyObject] else {
                print("Error: failed getting the bottom level dict out of user query")
                return
            }
            
            print("childDict value: \(childDictionary)")
            print("GETTING THE NAME OUT -> \(childDictionary["name"])")
            
            
            // Get the name & email
            
            
            guard let name = childDictionary["name"] as? String,
                let email = childDictionary["email"] as? String else {
                    print("error")
                    return
            }
            self.sellerInfo.name = name
            self.sellerInfo.email = email
            
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

            // USE MAIN QUEUE for UI updates
            
            dispatch_async(dispatch_get_main_queue(), {
                
                // Get picture for UI, may be optional
                
                if let imageURL = childDictionary["fb_pic_url"] as? String {
                    self.sellerInfo.imageURL = imageURL
                }
            
                self.itemSeller.text = ("Posted \(daysAgo) by \(self.sellerInfo.name ?? "")")
                
                // TODO put the seller info as a button or somwhere else so that it can be clicked on & user can view the seller info separately
                // maybe as a drag down arrow to view it down...
                
                print("TESTPRINT seller text: \(self.itemSeller.text)")
                
                print("TESTPRINT SELER INFO VAR: -> \(self.sellerInfo). name: \(self.sellerInfo.name!) email: \(self.sellerInfo.email)")

            })
        
        })
 
    }
    
    func showSellerInfo() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pvc = storyboard.instantiateViewControllerWithIdentifier("SellerInfoViewController") as UIViewController
        
        pvc.modalPresentationStyle = UIModalPresentationStyle.Custom
        pvc.transitioningDelegate = self
        pvc.view.backgroundColor = UIColor.blackColor()
        pvc.view.alpha = 0.75
        
        self.presentViewController(pvc, animated: true, completion: nil)
        

        
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
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
