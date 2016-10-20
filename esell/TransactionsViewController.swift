//
//  TransactionsViewController.swift
//  esell
//
//  Created by Angela Lin on 10/14/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit



class TransactionsViewController: UIViewController {
    
    
    enum Segment: Int {
        case postsBuying = 0
        case postsSelling = 1
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var containerView: UIView!
    
    
    // MARK: Data Variables
    
    weak var currentViewController: UITableViewController?
    
    
    // MARK:  VIEW DID LOAD
    
    override func viewDidLoad() {
        
        self.currentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BuyingTableViewController") as! BuyingTableViewController
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.currentViewController!)
        self.addSubview(self.currentViewController!.view, toView: self.containerView)
        
        super.viewDidLoad()
        
        self.navigationItem.title = "My Offers"
        
        setupSegmentedControl()
        
    }
    
    

    // Function for managing subview for container
    
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }
    
 
    func cycleFromViewController(oldViewController: UITableViewController, toViewController newViewController: UITableViewController) {
        oldViewController.willMoveToParentViewController(nil)
        self.addChildViewController(newViewController)
        self.addSubview(newViewController.view, toView:self.containerView!)
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
            },
                                   completion: { finished in
                                    oldViewController.view.removeFromSuperview()
                                    //oldViewController.removeFromParentViewController()
                                    newViewController.didMoveToParentViewController(self)
        })
    }
    
    
    
    // MARK: Functions for Segmented Control
    
    func setupSegmentedControl(){
        
        // attach function to segmentControl UI FOR WHEN VALUE CHANGED
        
        segmentedControl.addTarget(self, action: #selector(setupSegmentSwitchView), forControlEvents: UIControlEvents.ValueChanged)
        
        // set default selected index
        
        segmentedControl.selectedSegmentIndex = 0
        
    }
    
    
    func setupSegmentSwitchView() {
        
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.postsBuying.rawValue:
            
            print("  > selected segment: BIDS")
            
            
            // set container view content
            
            let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BuyingTableViewController") as! BuyingTableViewController
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
            self.currentViewController = newViewController
            
            
        case Segment.postsSelling.rawValue:
            
            print("  > selected segment: POSTS")
            
            // set container view content
            
            let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SellingTableViewController") as! SellingTableViewController
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
            self.currentViewController = newViewController
            
        default: break }
    }

    
}
