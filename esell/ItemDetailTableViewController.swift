//
//  ItemDetailTableViewController.swift
//  esell
//
//  Created by Angela Lin on 10/25/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class ItemDetailTableViewController: UITableViewController {

    @IBOutlet weak var itemTitle: UILabel!
    
    @IBOutlet weak var itemImage: UIImageView!

    @IBOutlet weak var itemDescription: UILabel!
    
    @IBOutlet weak var itemPrice: UILabel!
    
    @IBOutlet weak var itemSeller: UILabel!
    
    @IBOutlet weak var sellerProfileImage: UIImageView!
    
    @IBOutlet weak var pickupDescription: UILabel!
    
    @IBOutlet weak var pickupIconImage: UIImageView!

    
    // vars for post info
    var post = ItemListing(id: "temp")
    
    var postImage = UIImage()
    
    
    // vars for Seller
    
    var sellerAsUser = User(id: "temp")
    var daysAgo = "less than 1 day"
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove table view seperator lines
        tableView.separatorStyle = .None
        
        
        // Set an initial val for table rowheight
        
        tableView.estimatedRowHeight = 70 // Something reasonable to help ios render your cells
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        // Setup the UI elements with ItemListing attributes passed in
        
        
        
        
        itemTitle.text = post.title
        
        itemPrice.text = post.formattedPrice
        
        itemDescription.text = post.itemDescription
        
        pickupIconImage.hidden = false
        pickupDescription.text = post.pickupDescription
        
        
        itemImage.image = postImage
        itemImage.contentMode = .ScaleAspectFill
    

        
        // Handle date for posted how many days ago

        let now: NSDate = NSDate()
        
        switch now.daysFrom(post.createdDate) {
            
        case 0: daysAgo = "today"
        case 1: daysAgo = "1 day ago"
            
        default: daysAgo = String("\(now.daysFrom(post.createdDate)) days ago")
            
        }
    
        
        // Query Firebase to get SELLER INFO to appear, use author UID to get name
        let fireBase = FirebaseManager()
        
        fireBase.lookupSingleUser(userID: post.author) { (getUser) -> (Void) in
            
            self.sellerAsUser = getUser
            
            self.loadSellerInfo(self.sellerAsUser)
        }

        
    }

    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            switch(indexPath.row) {
            case 0: return 400
            case 1: return UITableViewAutomaticDimension
            case 2: return 2
            case 3: return UITableViewAutomaticDimension
            case 4: return UITableViewAutomaticDimension
            default: return 0
            }
        default: fatalError("unknown section")
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
        
        
        // Display seller name as text
        
        self.itemSeller.text = ("Posted \(self.daysAgo) \n\(self.sellerAsUser.name ?? "")")
        
        
    }
    
    
    
    // for image rounding
    
    private func roundUIView(view: UIView, cornerRadiusParams: CGFloat!) {
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadiusParams
    }
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//        
//        
//    }
//    
//    
    
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

extension UILabel{
    
    func requiredHeight() -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = self.font
        label.text = self.text
        
        label.sizeToFit()
        
        return label.frame.height
    }
}

