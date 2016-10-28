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
    
    // , FBSDKLoginButtonDelegate
//    let loginButton: FBSDKLoginButton = {
//        let button = FBSDKLoginButton()
//        button.readPermissions = ["email"]
//        return button
//    }()
    
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
        
//        view.addSubview(loginButton)
//        loginButton.center = view.center
//        
//        loginButton.delegate = self
//        loginButton.delegate = self
        
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
    
        
        // attach function to logout button
        logoutButton.addTarget(self, action: #selector(logoutTapped(_:)), forControlEvents: .TouchUpInside)

    }
    
//    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
//        
//        print("[LoginControl] User Logged In w/FBLoginManager")
//        print("[LoginControl] result: \(result)")
//        
//        if let error = error {
//            print(error.localizedDescription)
//            return
//        }
//            
//        else if result.isCancelled {
//            // Handle cancellations
//            print("[LoginControl] User canceled login ")
//        }
//            
//        else {
//            // If you ask for multiple permissions at once, you
//            // should check if specific permissions missing
//            if result.grantedPermissions.contains("email")
//                
//            {
//                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
//                
//                // Do work here (means no error using FB login manager)
//                
//                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
//                    
//                    if error != nil {
//                        // error handling if you get an error using Firebase Auth
//                        
//                        print(error)
//                        
//                    }
//                    
//                    // means no error using Firebase Auth, successfuly authenticated... do stuff here
//                    
//                    guard let uid = user?.uid else {
//                        return
//                    }
//                    
//                    // save FIRAuth's uid in UserDefaults
//                    print("CURRENT USER IS \(uid)")
//                    
//                    let defaults = NSUserDefaults.standardUserDefaults()
//                    defaults.setObject(uid, forKey: "uid")
//                    
//                })
//                
//                
//            }
//        }
//    }
//    
//    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
//        
//        try! FIRAuth.auth()!.signOut()
//        
//        print("[LoginControl] User Logged Out")
//        
//        self.dismissViewControllerAnimated(true, completion: nil)
//        if ((FIRAuth.auth()?.currentUser) == nil) {
//            
//            // Get a reference to the storyboard
//            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            
//            guard let loginPage = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController else {
//                fatalError()
//            }
//            
//            // Present/set the view controller
//            
//            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            appDelegate.window?.rootViewController = loginPage
//            
//            print("---> [appdel] set the LOGIN page as the root view")
//            
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
//
//    }
    

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
