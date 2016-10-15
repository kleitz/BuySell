//
//  ProfileViewController.swift
//  esell
//
//  Created by Angela Lin on 10/3/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up title
        
        self.navigationItem.title = "My Account"
        
        
        //   Attach logout button to logout function
        
        logoutButton.addTarget(self, action: #selector(logout), forControlEvents: .TouchUpInside)
        
        
    let ref = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com/")
        
        ref.child("posts").queryOrderedByKey().queryEqualToValue("-KTDGjOubxVLqwm3P2mt").observeSingleEventOfType(.ChildAdded, withBlock:  { (snapshot) in
            
            print("snapshot -> \(snapshot)")
            print("snapshot JKEY-> \(snapshot.key)")
            print("snapshot VAL -> \(snapshot.value)")
        })
        
        
//        let test = ref.child("posts").observeEventOfType(.Value) { (snapshot) in
//            print("snapshot print here: \(snapshot)")
//        }
        
        //print("TESTING QUERY : equal to post vlaue:  \(test)")

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
