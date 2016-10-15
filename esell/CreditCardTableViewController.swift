//
//  CreditCardTableViewController.swift
//  esell
//
//  Created by Angela Lin on 10/13/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

protocol FirebaseManagerBidDelegate: class {
    
    func bidComplete(manager: FirebaseManager, didComplete: Bool)
    
}

class CreditCardTableViewController: UITableViewController, UITextFieldDelegate, FirebaseManagerBidDelegate {
    
    @IBOutlet var creditCardTableView: UITableView!
   
  
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var creditCardTextField: UITextField!
    
    @IBOutlet weak var expiryMonthTextField: UITextField!
    
    @IBOutlet weak var expiryYearTextField: UITextField!
    

    @IBOutlet weak var CvcTextField: UITextField!
    
    @IBOutlet weak var checkoutButton: UIButton!

    
    
    var post = ItemListing(id: "test")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // get post info from parent container/controller
        
//        guard let parent = self.parentViewController as? PlaceBidViewController else {
//            fatalError("this iddn't work gettin gparent")
//            
//        }
//        
//        parent.post = post
//        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        checkoutButton.addTarget(self, action: #selector(prepareSaveBid), forControlEvents: .TouchUpInside)
    }


    // MARK: - Text field delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        return true
    }
    
    // MARK: = FUNCTIONS
    
    func prepareSaveBid() {

        // guard for non nil values
        
        let postID = post.id
        let price = post.price
        
        guard let name = nameTextField.text where name != "",
            let cardNumber = creditCardTextField.text where cardNumber != "",
            let month = expiryMonthTextField.text where month != "",
            let year = expiryYearTextField.text where year != "",
            let cvcNumber = CvcTextField.text where cvcNumber != "" else {
                
                print("Error filling out checkout form")
                
                popupNotifyIncomplete("Please fill out all fields")
                
                return
        }
        
        // Test some validation here for numerical fields  &  character lengths
        // TODO ... or just wait to use a real API or 3rd party that has validation built in?
        
        if isStringNumerical(creditCardTextField.text!) == false {
            print("Error: CC Number is NOT Numerical")
            popupNotifyIncomplete("Invalid credit card entry, please re-enter")
            return
        } else if creditCardTextField.text?.characters.count != 16 {
            print("Error: CC Number needs 16 digits")
            popupNotifyIncomplete("Invalid credit card entry, please check again")
            return
        } else {
            print("OK CC Number PASSES")
        }
        
        
        if isStringNumerical(month) == false || isStringNumerical(year) == false || month.characters.count != 2 || year.characters.count != 2  {
            print("Error: CC Expiry Month or Year is NOT Numerical")
            popupNotifyIncomplete("Invalid expiration date, please re-enter")
            return
        } else {
            print("OK CC Date PASSES")
        }
        if isStringNumerical(cvcNumber) == false || cvcNumber.characters.count > 4 {
            print("Error: CVC is NOT Numerical")
            popupNotifyIncomplete("Invalid CVC code, please re-enter")
            return
        } else {
            print("OK CC CVc PASSES")
        }
        
        
        // Get complete Object of CreditCard if all infomration passes
        
        let creditCardInfo = CreditCard(nameOnCard: name, cardNumber: cardNumber, expiryMonth: month, expiryYear: year)
        
        print("temp print creditCardInfo: \(creditCardInfo)")
        
        // Decide here whether it's cash or credit
        let hasPaidOnline: Bool  = false
        // if segmetn control == on the cash
        // then false
        // if segmetn on credit car dand the above balidaiton passes, then it's true
        
        
        // Pass to Firebase
        
        let fireBase = FirebaseManager()
        
        fireBase.delegateForBid = self
        
        
        
        // Save the bid to firebase. Removed credit card info as the parameter because shouldn't actually store it - just store the payment method (cash or credit), not the actual card info
        
        fireBase.saveBid(parentPostID: postID, bidAmount: price, hasPaidOnline: hasPaidOnline)
        
    }
    
    func bidComplete(manager: FirebaseManager, didComplete: Bool) {
        if didComplete == true {
            popupNotifyPosted(title: "Bid Completed", message: "Your bid has been sent!")
        } else {
            popupNotifyPosted(title: "Error sending bid", message: "Please try again, something went wrong")
        }
    }
    
    
    
    // Popup alert if missing fields
    
    func popupNotifyIncomplete(errorMessage: String){
        
        let alertController = UIAlertController(title: "Wait!", message:
            errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { action in
            print("test: pressed Dismiss")
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
    // Popup alert if Post Successful

    func popupNotifyPosted(title title: String, message: String){
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { action in
            
            // when click OK on alert, unwind back to previous view
            self.performSegueWithIdentifier("unwindToDetail", sender: self) })
        )
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func isStringNumerical(string : String) -> Bool {
        // Only allow numbers. Look for anything not a number.
        let range = string.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        return (range == nil)
    }
    
    deinit {
        
        print("(deinit) -> [CREDITCardController]")
    }
    
}


