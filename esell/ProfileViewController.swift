//
//  ProfileViewController.swift
//  esell
//
//  Created by Angela Lin on 10/3/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

import Firebase
import Crashlytics

class ProfileViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up title
        
        //let userInfo = User(id: "placeholder")
        
        self.navigationItem.title = "My Account"
        
        
        //   Attach logout button to logout function
        
        logoutButton.addTarget(self, action: #selector(logout), forControlEvents: .TouchUpInside)
        
        
        
        let button = UIButton(type: UIButtonType.RoundedRect)
        button.frame = CGRectMake(20, 50, 100, 30)
        button.setTitle("Crash", forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(button)

    }

    

    @IBAction func crashButtonTapped(sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }

    
    func logout() {
        
        // present the loginView again // TODO FIX LATER how this should work? it shoudl really log out the user (and then direct to log in page), rather than just going to the log in page to click 'log out' again.
        
        print("clicked log out button - so far no other action in this function - need to fix this flow")
        
        //performSegueWithIdentifier("segueToLogin", sender: logoutButton)
        
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let loginPage = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
        //self.presentViewController(vc, animated: true, completion: nil)
        
    }
    

    
    
}
