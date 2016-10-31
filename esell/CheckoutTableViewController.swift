//
//  CheckoutTableViewController.swift
//  esell
//
//  Created by Angela Lin on 10/13/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit



class CheckoutTableViewController: UITableViewController, UITextViewDelegate {
    
    // MARK: - IBOutlets
   
    @IBOutlet weak var itemInfoLabel: UILabel!
  

    @IBOutlet weak var offerAmount: UITextView!
    
    @IBOutlet weak var itemAskingPrice: UILabel!
    
    @IBOutlet weak var itemImage: UIImageView!
    
    
    // MARK: - Data Variables
    
    var post = ItemListing(id: "test")
    var postImage = UIImage()

    
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get post info from parent container/controller
        
        guard let parent = self.parentViewController as? CheckoutViewController else {
            fatalError("Error getting parentviewController")
        }
        
        self.post = parent.post
        self.postImage = parent.postImage
        
        itemInfoLabel.text = "\(self.post.title)"
        itemAskingPrice.text = "Asking price: \(self.post.formattedPrice)"
        //pickupInfo.text = post.pickupDescription
        
        itemImage.image = postImage
        
        
        // Remove table view seperator lines
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor(red: 252.0/255, green: 250.0/255, blue: 244.0/255, alpha: 1.0)
        
        // Looks for single or multiple taps. FOr dismissing keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        // set Description UITextField
        
        offerAmount.delegate = self
        offerAmount.text = "\(post.formattedPriceWithoutSymbol)"
        offerAmount.textColor = UIColor.lightGrayColor()
        offerAmount.layer.cornerRadius = 5.0
        offerAmount.layer.borderWidth = 0.5
        offerAmount.layer.borderColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1).CGColor

        
    }


    // MARK: - Text field delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "0"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    
    
    func isStringNumerical(string : String) -> Bool {
        // Only allow numbers. Look for anything not a number.
        let range = string.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        return (range == nil)
    }
    
    // Dismiss Keyboard functions
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - TableView settings
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // Gets the header view as a UITableViewHeaderFooterView and changes the text color
        
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        headerView.contentView.backgroundColor = UIColor(red: 242.0/255, green: 239.0/255, blue: 230.0/255, alpha: 1.0)
    }

    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.0
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        // Gets the header view as a UITableViewHeaderFooterView and changes the text color
        
        let footerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        footerView.contentView.backgroundColor = UIColor(red: 252.0/255, green: 250.0/255, blue: 244.0/255, alpha: 1.0)
    }
    
    
    
    deinit {
        
        print("(deinit) -> [checkout TableViewController]")
    }
    
}


