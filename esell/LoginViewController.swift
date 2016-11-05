//
//  LoginViewController.swift
//  esell
//
//  Created by Angela Lin on 9/26/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var guestLoginButton: UIButton!

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var loginView: UIView!

    @IBOutlet weak var signupView: UIView!

    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    @IBOutlet weak var emailLoginButton: UIButton!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("---> [login] FIR AUTH VALUE: \(FIRAuth.auth()?.currentUser?.email) // \(FIRAuth.auth()?.currentUser?.uid) ")
        
        // Go to main view if alreayd has auth
        
        if ((FIRAuth.auth()?.currentUser) != nil) {
            
            print("---> [login] logged in already, so present main View")
            
            
            // Get a reference to the storyboard
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let mainPage = storyboard.instantiateViewControllerWithIdentifier("mainNavig") as? UITabBarController else {
                
                print("---> [login] ERROR setting up main controller to go to")
                
                fatalError()
            }
            
            // Present/set the view controller
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController = mainPage
            
            print("---> [login] the root is set as : MAIN navig\n")
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["email", "public_profile"]
        
        guestLoginButton.addTarget(self, action: #selector(loginGuest), forControlEvents: .TouchUpInside)
        
        fbLoginButton.layer.cornerRadius = 10
        fbLoginButton.clipsToBounds = true
        
        
        emailLoginButton.addTarget(self, action: #selector(loginWithEmail), forControlEvents: .TouchUpInside)
        
        emailLoginButton.layer.cornerRadius = 10

        
        // Looks for single or multiple taps. FOr dismissing keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
    }
    
//    func setupLoginRegisterButton() {
//        loginRegisterButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
//        loginRegisterButton.topAnchor.constraintEqualToAnchor(inputsContainerView.bottomAnchor, constant: 12).active = true
//        loginRegisterButton.widthAnchor.constraintEqualToAnchor(inputsContainerView.widthAnchor).active = true
//        loginRegisterButton.heightAnchor.constraintEqualToConstant(50).active = true
//        
//    }
//    
//    func setupInputsContainer() {
//        
//        inputsContainerView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
//        
//        inputsContainerView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
//        inputsContainerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: -24).active = true
//        inputsContainerView.heightAnchor.constraintEqualToConstant(150).active = true
//    }
    
//    func setupSegmentControl() {
//        
//        // Set default segment that is Selected upon load
//        loginView.hidden = false
//        signupView.hidden = true
//        
//        segmentControl.selectedSegmentIndex = 0
//        
//        
//        // attach function to segmentControl UI
//        
//        segmentControl.addTarget(self, action: #selector(switchSegmentControl), forControlEvents: UIControlEvents.ValueChanged)
//        
//        
//    }
//    func switchSegmentControl() {
//        
//        switch segmentControl.selectedSegmentIndex {
//            
//        case 0:
//            loginView.hidden = false
//            signupView.hidden = true
//        case 1:
//            loginView.hidden = true
//            signupView.hidden = false
//        default: break
//        }
//        
//    }

    func loginWithEmail() {
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user: FIRUser?, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
                
            }
            
            // means success
            
            guard let userID = user?.uid else {
                print("error")
                return
            }
            
            
            // save FIRAuth's uid in UserDefaults
            print("CURRENT USER IS \(userID)")
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(userID, forKey: "uid")
            
            //TODO maybe should change all the NSUserDefaults stuff to ONE PLACE instead of login? I'm not getting the name here...
            
            
            // Success login, go to Main Page
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let mainPage = storyboard.instantiateViewControllerWithIdentifier("mainNavig") as? UITabBarController else {
                
                print("ERROR setting up main controller to go to")
                return
            }
            
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = mainPage

            
        })
       
    }
    
    
    func loginGuest() {
        
        FIRAuth.auth()?.signInAnonymouslyWithCompletion({ (user, error) in
            
            if let error = error {
                print("[LoginControl] ERROR anonymous login -> error: \(error.localizedDescription)")
                return
            }
            
            
            let isAnonymous = user!.anonymous  // true
            let uid = user!.uid
            
            print("UID: \(uid) . isAnonymous: \(isAnonymous)")
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(uid, forKey: "uid")
            defaults.setObject(nil, forKey: "userImageURL")
            defaults.setObject("Guest User", forKey: "userName")
            
            // Success login, go to Main Page
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let mainPage = storyboard.instantiateViewControllerWithIdentifier("mainNavig") as? UITabBarController else {
                
                print("ERROR setting up main controller to go to")
                return
            }
            
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = mainPage

        })
        
        
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
                    print("CURRENT USER IS \(uid)")
                    
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
                
                
                
                // lets save user name & info in NSDefaults
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(pictureURL, forKey: "userImageURL")
                defaults.setObject(userName, forKey: "userName")
                
            
                // do saving into firebase here
                
                let fireBase = FirebaseManager()
                
                fireBase.saveNewUserWithFacebookLogin(uid, name: userName, email: email, fbID: fbID, fbPicURL: pictureURL, fbURL: fbLink as String)
                

                
            }
        })
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    deinit {
        
        print("(deinit) -> [LoginControl] ")
    }


}

