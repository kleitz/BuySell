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
    
//    override func viewDidAppear(animated: Bool) {
//        if ((FIRAuth.auth()?.currentUser) != nil) {
//            
//            // go to another view IF USER IS ALREADY LOGGED In
//            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewControllerWithIdentifier("mainNavig")
//            self.presentViewController(vc, animated: true, completion: nil)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loginButton)
        loginButton.center = view.center
        
        loginButton.delegate = self
        
    }

    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        print("User Logged In w/FBLoginManager")
        
        
        print("result: \(result)")
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
            
        else if result.isCancelled {
            // Handle cancellations
            print("User canceled -no action yet")
        }
            
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
                
            {
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                // Do work
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    // do somethin here dunno what yet
                    
                    if error != nil {
                        /// error handling
                        print(error)
                        
                    }
                    
                    /// means no error, successfuly authenticated...
                    
                    guard let uid = user?.uid else {
                        return
                    }
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(uid, forKey: "uid")
                    
                    if ((FBSDKAccessToken.currentAccessToken()) != nil){
                        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler( { (connection, result, error) -> Void in
                            if (error != nil) {
                                
                                //process error
                                print(error)
                                
                            } else {
                                print("fetched user: \(result)")
                                let userName: NSString = result.valueForKey("name") as! NSString
                                print("usrename: \(userName)")
                                
                                let userID: NSString = result.valueForKey("id") as! NSString
                                print("userid: \(userID)")
                                
                                let email: NSString = result.valueForKey("email") as! NSString
                                print("email: \(email)")
                                
                                
                                // do saving into firebase here
                                
                                
                                let ref = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com/")
                                
                                let usersRef = ref.child("users").child(uid)
                                
                                let values = ["name": userName, "fb_id": userID, "email": email, "created_at": FIRServerValue.timestamp() ]
                                
                                usersRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                                    if err != nil {
                                        print(err)
                                        return
                                    }
                                    
                                    print("saved user succesufly in firebase DB")
                                })

                                
                                
                            }
                        })
                    }
                    
                    
                })
        
        
                
                // go to another view
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("mainNavig")
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()!.signOut()
        print("User Logged Out")
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


}

