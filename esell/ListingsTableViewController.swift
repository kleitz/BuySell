//
//  listingsTableViewController.swift
//  esell
//
//  Created by Angela Lin on 9/26/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ListingsTableViewController: UITableViewController {

    var posts = [ItemListing]()
    
    var postCount = 0 {
        willSet {
            print("in WillSet>> Called just before didset reloading tableview")
        }
        didSet {

            tableView.reloadData()
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("_tableView view loaded")
        
        // does adding dispatch help load when get FIRdatabase data?
//        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//
//        
//        
//        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        
        let post = posts[indexPath.row]
        
        
        // TODO IMplement better error handling/checking for this cell part
        
        if let title = post.title,
        let price = post.price,
            let desc = post.itemDescription {
            
            // set up the data gotten
            
            cell.titleText.text = title
            cell.priceText.text = price
            cell.descriptionText.text = desc
        }
        
        // do image stuff here TODO make load separately
        
        if let image = post.imageAsUIImage {
            cell.photo.image = image
        }
    
//        // this part uses URL
//        // get the image stuff out
//        
//        guard let url = NSURL(string: imageURL) else {
//            print("error getting imageurl to nsurl")
//            fatalError()
//        }
//        
//        if let imageData = NSData(contentsOfURL: url) {
//            cell.photo.image = UIImage(data: imageData)
//            cell.photo.contentMode = .ScaleAspectFit
//        }
        
        
        
        // each cell returns
        
        print("Cell returned... [cellForRowAtIndexPath]")
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected row@ \(indexPath.row)")
        
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print(" >> started segue")
        
        if let identifier = segue.identifier {
            
            switch identifier {
                
            case "segueToItemDetail":
                
                if let cell = sender as? UITableViewCell {
                    
                    let rowIndex = self.tableView.indexPathForCell(cell)!.row
                    
                    guard let itemDetailController = segue.destinationViewController as? ItemDetailViewController else {
                        fatalError("seg failed")
                    }
                    
                    itemDetailController.post = posts[rowIndex]
                }
            default: break
            }
        }
        
    }
    
    

    
    // MARK: for logging view controller lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(">> view appearin -> Listings")
    }
    
    deinit {
        print("(deinit) -> Listings")
    }
    
    
}
