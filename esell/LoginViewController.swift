//
//  ViewController.swift
//  esell
//
//  Created by Angela Lin on 9/26/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    

    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loginButton)
        loginButton.center = view.center
        
        loginButton.delegate = self
        
    }

    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        
        print("[LoginControl] User Logged In w/FBLoginManager")
        print("[LoginControl] result: \(result)")
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
            
        else if result.isCancelled {
            // Handle cancellations
            print("[LoginControl] User canceled login ")
        }
            
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
                
            {
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                // Do work here (means no error using FB login manager)
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    
                    if error != nil {
                        // error handling if you get an error using Firebase Auth
                        
                        print(error)
                        
                    }
                    
                    // means no error using Firebase Auth, successfuly authenticated... do stuff here
                    
                    guard let uid = user?.uid else {
                        return
                    }
                    
                    // save FIRAuth's uid in UserDefaults
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(uid, forKey: "uid")
                    


                    if ((FBSDKAccessToken.currentAccessToken()) != nil){
                        
                        // Send FBSDK graph request to get user info parameters from Facebook
                        
                        self.returnUserDatafromFBGraphRequest(withAuthUID: uid)
                        
                        // Success login, go to Main Page
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let mainPage = storyboard.instantiateViewControllerWithIdentifier("mainNavig") as? UITabBarController else {
                            
                            print("ERROR setting up main controller to go to")
                            return
                        }
                        
                        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
                        
                        appDelegate.window?.rootViewController = mainPage
                        
                    }
                    
                })


            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        try! FIRAuth.auth()!.signOut()
        
        print("[LoginControl] User Logged Out")
    }
    
    func returnUserDatafromFBGraphRequest(withAuthUID uid: String){
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(normal), link"]).startWithCompletionHandler( { (connection, result, error) -> Void in
            if (error != nil) {
                
                //process error
                
                print("[LoginControl] Error FBSDKgraph request \(error.localizedDescription)")
                
            } else {
                
                // successful request, do work
                
                let userName = result.valueForKey("name") as! String
                
                let fbID = result.valueForKey("id") as! String
                
                let email = result.valueForKey("email") as! String
                
                let fbLink = result.valueForKey("link") as! String
                
                guard let picture = result.valueForKey("picture") as? NSDictionary,
                let pictureData = picture.valueForKey("data") as? NSDictionary,
                let pictureURL = pictureData.valueForKey("url") as? String else {
                    print("[LoginControl] Error getting fb pic url")
                    return
                }
                
                print("[LoginControl] fetched user from fb: \(email)")
                
                
                // do saving into firebase here
                
                let fireBase = FirebaseManager()
                
                fireBase.createNewUserInFirebase(uid, name: userName, email: email, createdAt: FIRServerValue.timestamp(), fbID: fbID, fbPicURL: pictureURL, fbURL: fbLink as String)
                

                
            }
        })
    }
    
//    func signedIn(user: FIRUser?) {
//        MeasurementHelper.sendLoginEvent()
//
//        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
//        AppState.sharedInstance.photoUrl = user?.photoURL
//        AppState.sharedInstance.signedIn = true
//        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
//        performSegueWithIdentifier(Constants.Segues.SignInToFp, sender: nil)
//        
//    }
    
    
    
    deinit {
        
        print("(deinit) -> [LoginControl] ")
    }


}

