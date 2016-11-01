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

        sourceViewController = self.parentViewController?.tabBarController as! PostTabBarController
        
        tableView.backgroundColor = UIColor(red: 252.0/255, green: 250.0/255, blue: 244.0/255, alpha: 1.0)
        
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
        
        cell.priceText.text = post.formattedPrice
        cell.titleText.text = post.title
        cell.descriptionText.text = post.itemDescription
        cell.locationText.text = post.pickupDescription.componentsSeparatedByString(",")[0] ?? ""
        
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

        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(" >> selected row@ \(indexPath.row)")
        
    }

    
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
                    
                    print("PRINT DATA before sgue: \(itemDetailController.post.title): \(itemDetailController.post.formattedPrice)")
                    
                    // for passing image
                    if let image: UIImage = sourceViewController.imageCache[sourceViewController.posts[rowIndex].imageURL!] {
                        itemDetailController.image = image
                    }
                }
            default: break
            }
        }
        
    }
    
    
    deinit {
        print("(deinit) -> Listings")
    }
    
    
}
