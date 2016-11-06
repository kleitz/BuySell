//
//  CreateAccountViewController.swift
//  esell
//
//  Created by Angela Lin on 11/5/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateAccountViewController: UIViewController {

   
    @IBAction func closeButton(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var passwordRetypeText: UITextField!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBAction func createAccount(sender: UIButton) {
        
        prepareSaveFields()
        
        print("click create account")
        
        guard let name = nameText.text where name != "" else {
            
            self.popupNotifyIncomplete("You must fill out all fields")
            return
        }
        
        guard let password = passwordText.text where password != "" else {
            self.popupNotifyIncomplete("You must fill out all fields")
            return
        }
        
        guard let passwordRetype = passwordRetypeText.text where passwordRetype != "" else {
            self.popupNotifyIncomplete("You must fill out all fields")
            return
        }
        
        if password != passwordRetype {
            
            self.popupNotifyIncomplete("Password confirmation must match")
            return
            
        }
        
        guard let email = emailText.text where email != "" else {
            self.popupNotifyIncomplete("You must fill out all fields")
            return
        }
        
        let fullName = name
        
        
        let fireBase = FirebaseManager()
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user: FIRUser?, error) in
            
            if let error = error {
                print(error)
                print(error.localizedDescription)
                
                
                switch error.code {
                case 17008:
                    self.popupNotifyIncomplete("Please check that your email is typed correctly")
                case 17011: // email is wrong
                    self.popupNotifyIncomplete("Incorrect email or password, please re-enter")
                case 17009: // password is wrong
                    self.popupNotifyIncomplete("Incorrect email or password, please re-enter")
                case 17007: // email already in use
                    self.popupNotifyIncomplete("Email address already in use, please re-enter")
                default:
                    self.popupNotifyIncomplete("Incorrect email or password, please re-enter")
                }
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
            defaults.setObject(name, forKey: "userName")
            
            // Save
            
            fireBase.saveNewUserWithEmailLogin(userID, name: fullName, email: email)

            
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Looks for single or multiple taps. FOr dismissing keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
    }

    
    func createAccount() {
        
        
        
    }
    
    func prepareSaveFields() {

        
        
        
    }
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func popupNotifyIncomplete(errorMessage: String){
        
        let alertController = UIAlertController(title: "Login Error", message:
            errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil ))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}
