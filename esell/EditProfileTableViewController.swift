//
//  EditProfileTableViewController.swift
//  esell
//
//  Created by Angela Lin on 11/7/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import FirebaseAuth

class EditProfileTableViewController: UITableViewController {

    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var cameraIcon: UIImageView!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var locationText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationItem.title = "Edit Profile"
        
        tableView.separatorStyle = .None
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(clickSave(_:)))
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(clickCancel(_:)))
        
        self.navigationItem.setRightBarButtonItem(editButton, animated: true)
        self.navigationItem.setLeftBarButtonItem(cancelButton, animated: true)
        
        
        // set Text fields UI
        
        locationLabel.hidden = true
        locationText.hidden = true
        
        
        
        //FIRAuth.auth()?.email
        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }

    
    
    func clickSave(button: UIBarButtonItem)
    {
        print("clickSave")
        
        // do the saving onto Firebase here
    }
    
    func clickCancel(button: UIBarButtonItem)
    {
        print("clickCnacnel")
        self.performSegueWithIdentifier("unwindToProfile", sender: self)
    }
    
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    deinit{
        print(" >>  deinit Killed EditProfile")
    }
    
}
