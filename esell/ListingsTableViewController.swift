//
//  listingsTableViewController.swift
//  esell
//
//  Created by Angela Lin on 9/26/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import Firebase

class ListingsTableViewController: UITableViewController {

    let cellId = "cell"
    var posts = [ItemListing]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchPosts()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        
        let post = posts[indexPath.row]
        
        guard let title = post.title,
        let price = post.price,
        let desc = post.itemDescription else {
            print("error getting info for cell")
            return cell
        }
        
        cell.titleText.text = title
        cell.priceText.text = price
        cell.descriptionText.text = desc
        
        print("Cell returned safely...")
        return cell
        
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
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
    
    func fetchPosts() {
        
        print("running fetchPosts()")
        print("unadded posts count; \(posts.count)")
        
        let ref = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com/")
        
        ref.child("posts").observeEventType(.ChildAdded, withBlock: { (snapshot
            ) in
            
            print(snapshot)
            
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else {
                print("error unwrapping post")
                return
            }
            
            let post = ItemListing()
            
            post.title = dictionary["title"] as? String
            post.itemDescription = dictionary["description"] as? String
            post.price = dictionary["price"] as? String
            post.author = dictionary["author"] as? String
            
            print("PRINT POST title: \(post.title)")
            
            // put into the array
            print("APPENDED \n")
            self.posts.append(post)
            
            // need to put on main queue
            
            dispatch_async(dispatch_get_main_queue(), {
                
                print(" > reload table view")
                
                self.tableView.reloadData()
                
                print("added posts count; \(self.posts.count)")
                
            })
            
            }, withCancelBlock: { (error) in
                print("fetchPosts error: \(error.localizedDescription)")
        })
        
        
        
    }

}
