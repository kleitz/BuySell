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

    let cellId = "cell"
    var posts = [ItemListing]()
    
    @IBOutlet weak var logoutButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // does adding dispatch help load?
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        
        self.fetchPostsFromFirebase()
        
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
      //   Attach logout button to logout function
        logoutButton.addTarget(self, action: #selector(logout), forControlEvents: .TouchUpInside)
        
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
        
        guard let title = post.title,
        let price = post.price,
        let desc = post.itemDescription,
        let imageURL = post.imageURL else {
            print("error getting info for cell")
            fatalError()
        }
        
        // get the image stuff out
        
        guard let url = NSURL(string: imageURL) else {
            print("error getting imageurl to nsurl")
            fatalError()
        }
        
        if let imageData = NSData(contentsOfURL: url) {
            cell.photo.image = UIImage(data: imageData)
        }
        
        // set the string stuff
        
        cell.titleText.text = title
        cell.priceText.text = price
        cell.descriptionText.text = desc
        
        // each cell returns
        
        print("Cell returned/reloaded safely... [tablewview.cellForRowAtIndexPath]")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func fetchPostsFromFirebase() {
        
        print("/n > running fetchPosts()...")
        
        let ref = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com/")
        
        ref.child("posts").observeEventType(.ChildAdded, withBlock: { (snapshot
            ) in
            
            print(snapshot)
            
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else {
                print("error unwrapping post")
                fatalError()
            }
            
            let post = ItemListing()
            
            post.title = dictionary["title"] as? String
            post.itemDescription = dictionary["description"] as? String
            post.price = dictionary["price"] as? String
            post.author = dictionary["author"] as? String
            post.imageURL = dictionary["image_url"] as? String
            
            // test print the date ...
            guard let postDate = dictionary["created_at"] as? NSTimeInterval else {
                print("error getting itme out")
                fatalError()
            }
    
            post.createdDate = NSDate(timeIntervalSinceReferenceDate: postDate/1000)

            // PUT INTO LOCAL ARRAY
            self.posts.append(post)
            
            print("APPENDED in array so table can read. posts.count: \(self.posts.count)")
            
            // need to put on main queue (I tried it and it still works if not on main queue??)
            dispatch_async(dispatch_get_main_queue(), {
                
                self.tableView.reloadData()
                
                print(" > reload table view")
                
            })
            
            }, withCancelBlock: { (error) in
                print("fetchPosts error: \(error.localizedDescription)")
        })
        
    }
    
    
    func logout() {
        
        // present the loginView again
        print("clicked log out button on posts view - so far other action in this function")
        //performSegueWithIdentifier("segueToLogin", sender: logoutButton)
        
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let loginPage = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
        //self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        print(">> view appearin -> Listings")
    }
    
    deinit {
        
        print("(deinit) -> Listings")
    }
    
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

}
