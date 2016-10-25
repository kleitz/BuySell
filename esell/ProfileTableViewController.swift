//
//  ProfileTableViewController.swift
//  esell
//
//  Created by Angela Lin on 10/20/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    

    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Remove table view seperator lines
        tableView.separatorStyle = .None
        
        
        // get userInfo from NSUserDefaults
        
        let defaults = NSUserDefaults.standardUserDefaults()
    
        
        guard let userImageURL = defaults.stringForKey("userImageURL") else {
            fatalError("failed Profile")
        }
        guard let userName = defaults.stringForKey("userName") else {
            fatalError("failed Profile")
        }
        
        
        if let url = NSURL(string: userImageURL) {
            if let imageData = NSData(contentsOfURL: url) {
                self.profileImage.image = UIImage(data: imageData)
            }
        }
        
        
        self.profileName.text = userName
        
        
//        
//    ///backup is: retrieve data from Firebase
//        
//        guard let userID = defaults.stringForKey("uid") else {
//            fatalError("failed getting nsuserdefaults uid")
//        }
//     
//        
//        let fb = FirebaseManager()
//        
//        fb.fetchUserInfoFromFirebase(sellerUID: userID) { (getUser) in
//            
//            
//            if let url = NSURL(string: getUser.imageURL) {
//                if let imageData = NSData(contentsOfURL: url) {
//                    self.profileImage.image = UIImage(data: imageData)
//                }
//            }
//            
//            
//            self.profileName.text = getUser.name
//            
//        }
        


    }
}
