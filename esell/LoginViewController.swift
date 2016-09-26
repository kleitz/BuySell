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
        print("User Logged In")
        
        
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
                })
        
        
                
                // go to another view
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("listingsTable")
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()!.signOut()
        print("User Logged Out")
    }

}

