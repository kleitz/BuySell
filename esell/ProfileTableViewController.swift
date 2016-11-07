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
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {
        
    }
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    

    @IBOutlet weak var profileNameTextView: UITextView!
    
    @IBOutlet weak var editAccountButton: UIButton!
    
    @IBAction func clickEditAccount(sender: UIButton) {
        
        self.performSegueWithIdentifier("segueToEditProfile", sender: self)
    }
    
    @IBAction func clickLogoutButton(sender: UIButton) {
        print("clicked log out button")
        
        let loginManager = FBSDKLoginManager()
        
        loginManager.logOut()
        
        try! FIRAuth.auth()!.signOut()
        
        
        print("[LoginControl] User Logged Out")
        //self.dismissViewControllerAnimated(false, completion: nil)
        print("in STACK: \(self.navigationController?.viewControllers.count)" )
        
        let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        
        let loginPageNav = UINavigationController(rootViewController: loginPage)
        loginPageNav.navigationBarHidden = true
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = loginPageNav

        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        self.navigationItem.title = "Profile"

        tableView.separatorStyle = .None
        
//        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(clickEdit(_:)))
//        self.navigationItem.setRightBarButtonItem(editButton, animated: true)
        
        guard let user = FIRAuth.auth()?.currentUser else {
            print("ERROR")
            return
        }
        
        print("CUCRENT USER : \(user) displayNmae\(user.displayName). proivder. \(user.providerID) \(user.providerData) id: \(user.uid). is anonymous? \(user.anonymous) ")
        
        
        
        if user.anonymous {
            
            self.profileName.text = "Guest User"
            self.profileImage.image = UIImage(named:"profile_large")
            
        } else {
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            guard let userName = defaults.stringForKey("userName") else {
                self.profileName.text = "Unknown User"
                print("Failed getting user name")
                return
            }
            
            self.profileNameTextView.text = userName
            self.profileNameTextView.editable = true
            
            self.profileName.text = userName
            
            
            
            guard let userImageURL = defaults.stringForKey("userImageURL") else {
                self.profileImage.image = UIImage(named:"profile_large")
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

    }
    
    func clickEdit(button: UIBarButtonItem)
    {
        print("clickEdit")
        
        
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            
            switch identifier {
                
                case "segueToEditProfile":
                
                    guard let editProfileVC = segue.destinationViewController as? EditProfileTableViewController else {
                        print("segue failed")
                        return
                }
                
                editProfileVC.userImage.image = self.profileImage.image
                
                editProfileVC.nameText.text = self.profileName.text
                
                
                
            default: break
            }
            
        }

    }

    
    private func roundUIView(view: UIView, cornerRadiusParams: CGFloat!) {
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadiusParams
    }
}
