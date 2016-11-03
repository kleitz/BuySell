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
        

        
        guard let user = FIRAuth.auth()?.currentUser else {
            print("ERROR")
            return
        }
        
        print("CUCRENT USER : \(user) displayNmae\(user.displayName). id: \(user.uid). is anonymous? \(user.anonymous)")
        
        
        
        if user.anonymous {
            
            self.profileName.text = "Guest User"
            self.profileImage.image = UIImage(named:"profile_large")
            
        } else {
        
        self.profileName.text = user.displayName
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard let userImageURL = defaults.stringForKey("userImageURL") else {
            print("Failed getting profile picture")
            return
        }
        
        if let url = NSURL(string: userImageURL) {
            if let imageData = NSData(contentsOfURL: url) {
                self.profileImage.image = UIImage(data: imageData)
                self.profileImage.contentMode = .ScaleAspectFill
                
                self.roundUIView(self.profileImage, cornerRadiusParams: self.profileImage.frame.size.width / 2)
            }
        }
        }

        
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
    

    private func roundUIView(view: UIView, cornerRadiusParams: CGFloat!) {
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadiusParams
    }
}
