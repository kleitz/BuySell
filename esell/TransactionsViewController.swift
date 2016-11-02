//
//  TransactionsViewController.swift
//  esell
//
//  Created by Angela Lin on 10/14/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

protocol BuyingStillLoadingDelegate {

    func stopLoading(manager: BuyingTableViewController, isFinishedLoading: Bool)
}

protocol SellingStillLoadingDelegate {

    func stopLoading(manager: SellingTableViewController, finishedLoading: Bool)
}

class TransactionsViewController: UIViewController, BuyingStillLoadingDelegate, SellingStillLoadingDelegate {
    
    
    enum Segment: Int {
        case postsBuying = 0
        case postsSelling = 1
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: Data Variables
    
    weak var currentViewController: UITableViewController?
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
        
    }
    // MARK:  VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.currentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BuyingTableViewController") as! BuyingTableViewController
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.currentViewController!)
        self.addSubview(self.currentViewController!.view, toView: self.containerView)
        
        
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
            activityIndicator.startAnimating()
        
            // set container view content
            
            let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BuyingTableViewController") as! BuyingTableViewController
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
            self.currentViewController = newViewController
            
            newViewController.delegate = self
            
        case Segment.postsSelling.rawValue:
            activityIndicator.startAnimating()
            
            // set container view content
            
            let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SellingTableViewController") as! SellingTableViewController
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
            self.currentViewController = newViewController
            
            newViewController.delegate = self
            
        default: break }
    }

    
    func stopLoading(manager: BuyingTableViewController, isFinishedLoading: Bool) {
        print("[buying] IN THE DELEGEAT FUNC; stop")
        if isFinishedLoading {
            activityIndicator.stopAnimating()
        }
    }
    
    
    func stopLoading(manager: SellingTableViewController, finishedLoading: Bool) {
        print("[sell] IN THE DELEGEAT FUNC; stop")
        if finishedLoading {
            activityIndicator.stopAnimating()
        }
    }
}
