//
//  TransactionsViewController.swift
//  esell
//
//  Created by Angela Lin on 10/14/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class TransactionsViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var buyingList = []
    
    var sellingList = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Get the userID from userdefaults to save as "author" key
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard let userID = defaults.stringForKey("uid") else {
            print("failed getting nsuserdefaults uid")
            return
        }
        
        print("UID: \(userID)")
        
        
        // Get query from firebase
        // 1: list of things I've bidded for
        
        let fireBase = FirebaseManager()
        
        //fireBase.queryForBidsCreated(byUserID: userID)

        
        // 2: list of things I posted
        
        
        //fireBase.queryForPostsCreated(byUserID: userID, withCompletionHandler: for something
        fireBase.queryForPostsCreated(byUserID: userID) { (postsCreated) in
            print(postsCreated)
            
            self.sellingList = postsCreated
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
