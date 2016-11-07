//
//  SellerInfoViewController.swift
//  esell
//
//  Created by Angela Lin on 10/6/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseAuth

class SellerInfoViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var sellerNameLabel: UILabel!
    
    @IBOutlet weak var sellerLocationLabel: UILabel!
    
    
    @IBOutlet weak var emailButton: UIButton!
    
    @IBAction func clickEmailButton(sender: UIButton) {
        
        if FIRAuth.auth()?.currentUser?.anonymous == true {
            popupNotifyWarnGuestUser()
            return
        }
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
    }
    
// TODO : need to fix bug with opening email window (when it goes back to app, the bottom bounds is shorter)
//    override func viewWillAppear(animated: Bool) {
//        print("..... self view bounds: \(self.view.bounds)")
//        print("      self view frame: \(self.view.frame)")
//        
//        
//        self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
//        self.view.setNeedsDisplay()
//        self.view.layoutIfNeeded()
//        
//    }

    var userInfo = User(id: "temp")
    var userImage = UIImage(named:"")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Seller Profile"
        
        self.sellerNameLabel.text = self.userInfo.name

        
        self.profileImage.image = userImage
        self.profileImage.contentMode = .ScaleAspectFill
        self.roundUIView(self.profileImage, cornerRadiusParams: self.profileImage.frame.size.width / 2)
        
        
        // Button
        
        emailButton.layer.cornerRadius = 10
        
    }

    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setSubject("[BuySell] About Your Item")
        mailComposerVC.setToRecipients(["\(userInfo.email)"])
        mailComposerVC.setMessageBody("Hi \(userInfo.name),", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        
        let alertController = UIAlertController(title: "Unable to send email", message:
            "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    private func roundUIView(view: UIView, cornerRadiusParams: CGFloat!) {
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadiusParams
    }

    
    func popupNotifyWarnGuestUser(){
        
        let alertController = UIAlertController(title: "Wait!", message:
            "You must log out as Guest User and register an account first", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    

    deinit {
        
        print("(deinit) -> [SELLERViewController]")
    }

}
