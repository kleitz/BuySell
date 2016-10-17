//
//  PlaceBidViewController.swift
//  esell
//
//  Created by Angela Lin on 10/13/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class CheckoutViewController: UIViewController {

    
    @IBOutlet weak var paymentMethodSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var mainContainerView: UIView!
    
    
    var post = ItemListing(id: "test")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("post received??? in CheckoutViewController \(post.id) & price: \(post.price)")
        
        
        // Add the credit card table into the viewcontroller
        
        let storyboard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
        
        let ccViewController = storyboard.instantiateViewControllerWithIdentifier("CreditCardTableViewController") as! CreditCardTableViewController
            
        // Add child view controller
        self.addChildViewController(ccViewController)
        
        // Add child view as subview [of parent]
        self.mainContainerView.addSubview(ccViewController.view)
        
        // Configure child view
        ccViewController.view.frame = self.mainContainerView.bounds
        ccViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Notify the child view controller
        ccViewController.didMoveToParentViewController(self)
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
