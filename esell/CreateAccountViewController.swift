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

    @IBOutlet weak var closeWindowButton: UIButton!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var passwordRetypeText: UITextField!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        closeWindowButton.addTarget(self, action: #selector(closeViewController), forControlEvents: .TouchUpInside)
        
        
        createAccountButton.addTarget(self, action: #selector(createAccount), forControlEvents: .TouchUpInside)
    }

    
    func createAccount() {
        
        prepareSaveFields()
    
        
        guard let name = nameText.text where name != "" else {
            //popup
            return
        }
        
        guard let password = passwordText.text where password != "" else {
            //popup
            return
        }
        // check that passwords match and has min # of charas
        guard let email = emailText.text where email != "" else {
            //popup
            return
        }
        
        let fullName = name
        
        
        let fireBase = FirebaseManager()
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user: FIRUser?, error) in
            
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
    
    func prepareSaveFields() {

        
        
        
    }
    func closeViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
