//
//  ProfileTableViewController.swift
//  esell
//
//  Created by Angela Lin on 10/20/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.navigationItem.title = "Profile"
        
        
        // Remove table view seperator lines
        tableView.separatorStyle = .None
        
        // get userInfo from NSUserDefaults
        
        let defaults = NSUserDefaults.standardUserDefaults()
    
        
        guard let userImageURL = defaults.stringForKey("userImageURL"),
            let userName = defaults.stringForKey("userName")  else {
            fatalError("failed Profile")
        }
        
        if let url = NSURL(string: userImageURL) {
            if let imageData = NSData(contentsOfURL: url) {
                self.profileImage.image = UIImage(data: imageData)
            }
        }
        
        self.profileName.text = userName

        
        // attach function to logout button
        logoutButton.addTarget(self, action: #selector(logoutTapped(_:)), forControlEvents: .TouchUpInside)

    }
    
    func logoutTapped(button: UIButton) {
        
        let loginManager = FBSDKLoginManager()
        
        loginManager.logOut()
        
        try! FIRAuth.auth()!.signOut()
        
        print("[LoginControl] User Logged Out")
        
        let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        
        let loginPageNav = UINavigationController(rootViewController: loginPage)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = loginPageNav
        
    }
}
