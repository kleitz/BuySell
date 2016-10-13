//
//  listingsTableViewController.swift
//  esell
//
//  Created by Angela Lin on 9/26/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit



class ListingsTableViewController: UITableViewController {
    
    var sourceViewController = PostTabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("_tableView view loaded")
        
        sourceViewController = self.parentViewController?.tabBarController as! PostTabBarController
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sourceViewController.posts.count
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        
        let post = sourceViewController.posts[indexPath.row]
        
        
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
        // does adding dispatch help load when get FIRdatabase data?
        
        // temp set image
        cell.photo.image = UIImage(named:"shopbag")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            // Jump in to a background thread to get the image for this item
                        
            // Check our image cache for the existing key. This is just a dictionary of UIImages
            
            guard let imageURL = post.imageURL else {
                fatalError()
            }
            
            // Check if image already exists in imageCache
            
            let image: UIImage? = self.sourceViewController.imageCache[imageURL]
            
            
            if (image == nil) {
                print("--> start request grab imageData from URLstring")
                
                // If the image does not exist, we need to download it
                guard let imgURL = NSURL(string: imageURL) else {
                    fatalError("error unwrap string to NSURL")
                }
                
                // Download an NSData representation of the image at the URL
                let urlRequest = NSURLRequest(URL: imgURL)
                
                
                let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
                    if error == nil {
                        
                        guard let unwrappedData = data else {
                            fatalError()
                        }
                        
                        guard let image = UIImage(data: unwrappedData) else {
                            fatalError()
                        }
                        
                        // Store the image in to our cache
                        
                        self.sourceViewController.imageCache[imageURL] = image
                        
                        
                        // Display image (using main thread)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.photo.image = image
                            cell.photo.contentMode = .ScaleAspectFit
                        })
                        
                    } else {
                        
                        print(error?.localizedDescription)
                    }
                })
                
                task.resume()
                
            } else {
                print("--> start show image, already in imageCache")
                // Display image (using main thread)
                
                dispatch_async(dispatch_get_main_queue(), {
                    cell.photo.image = image
                    cell.photo.contentMode = .ScaleAspectFit
                })
            }
            
            
        }
        
        // each cell returns
        
        print("Cell returned... [cellForRowAtIndexPath]")
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(" >> selected row@ \(indexPath.row)")
        
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
                
            case "segueTableToItemDetail":
                
                if let cell = sender as? UITableViewCell {
                    
                    let rowIndex = self.tableView.indexPathForCell(cell)!.row
                    
                    guard let itemDetailController = segue.destinationViewController as? ItemDetailViewController else {
                        fatalError("seg failed")
                    }
                    
                    itemDetailController.post = sourceViewController.posts[rowIndex]
                    
                    // for passing image
                    if let image: UIImage = sourceViewController.imageCache[sourceViewController.posts[rowIndex].imageURL!] {
                        itemDetailController.image = image
                    }
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
