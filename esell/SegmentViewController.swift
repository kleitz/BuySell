//
//  SegmentViewController.swift
//  
//
//  Created by Angela Lin on 10/3/16.
//
//

import UIKit


enum Segment: Int {
    case collection = 0
    case table = 1
}

protocol FirebaseManagerDelegate: class {
    func returnData(manager: FirebaseManager, data: [ItemListing]?)
    func returnError(manager: FirebaseManager, error: NSError?)
}

class SegmentViewController: UIViewController, FirebaseManagerDelegate {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var mainView: UIView!
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        self.tabBarController?.setTabBarVisible(true, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up segment control images and attach function
        
        setupSegmentControl()
        
        segmentControl.tintColor = UIColor(red: 252.0/255, green: 250.0/255, blue: 244.0/255, alpha: 1.0)
    
        
        // Set up title
        
        self.navigationItem.title = "Browse"
        
        
        // Fetch data
        
        let firebaseInstance = FirebaseManager()
        
        firebaseInstance.delegate = self
        
        firebaseInstance.fetchPostsForBrowse()
        
        
    }
    
    // Delegate methods
    
    func returnData(manager: FirebaseManager, data: [ItemListing]?) {
        
        print("\n [>> delegate method.] 1 PostData returned.")
        
        guard let postDataSet = data else {
            fatalError("fail to unwrap post from data call")
        }
        
        // Store the posts in TabBarController (data will be sourced from there)
        
        let postTabBarController = self.tabBarController as! PostTabBarController
        
        postTabBarController.posts = postDataSet
        
        
        print("INSERTED in array in TBController. posts.count: \(postTabBarController.posts.count)")
        
        
        // Reload UI after data update
        
        self.tableViewController.tableView.reloadData()
        
        self.collectionViewController.collectionView.reloadData()
    }
    
    
    func returnError(manager: FirebaseManager, error: NSError?) {
        
        /// TODO BETTER ERROR HANDLING
        
        if let error = error {
            print("fetchPosts error: \(error.localizedDescription)")
        }
        
    }
    
    // Setup segment control methods
    
    func setupSegmentControl() {

        // attach function to segmentControl UI
        
        segmentControl.addTarget(self, action: #selector(setupSegmentSwitchView), forControlEvents: UIControlEvents.ValueChanged)


        // Set default segment that is Selected upon load
        
        segmentControl.selectedSegmentIndex = Segment.collection.rawValue
        
//        tableViewController.view.hidden = false
//        collectionViewController.view.hidden = true

    }
    
    func setupSegmentSwitchView() {
        switch segmentControl.selectedSegmentIndex
        {
            
        case Segment.collection.rawValue:
            print(" > select collection")
            tableViewController.view.hidden = true
            collectionViewController.view.hidden = false
            
        case Segment.table.rawValue:
            print(" > select table")
            tableViewController.view.hidden = false
            collectionViewController.view.hidden = true

        default: break;
        }
    }
    

    
    lazy var tableViewController: ListingsTableViewController = {
        
        // Load storyboard
        
        let storyboard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
        
        // Instantiate view controller
        
        var viewController = storyboard.instantiateViewControllerWithIdentifier("ListingsTableViewController") as! ListingsTableViewController
        
        // Add this as a CHILD view controller
        
        self.addViewControllerAsChildViewController(viewController)
        print(" >> Segment.mainview: just added table view controller \n")
        
        
        return viewController
        
    }()

    
    
    lazy var collectionViewController: ListingsCollectionViewController = {
        
        // Load storyboard
        
        let storyboard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
        
        // Instantiate view controller
        
        var viewController = storyboard.instantiateViewControllerWithIdentifier("ListingsCollectionViewController") as! ListingsCollectionViewController
        
        // Add this as a CHILD view controller
        
        self.addViewControllerAsChildViewController(viewController)
        print(" >> Segment.mainview: just added collection view controller \n")
        
        
        return viewController
        
    }()
    
    
    private func addViewControllerAsChildViewController(viewController: UIViewController){
        
        // Add child view controller
        addChildViewController(viewController)
        
        // Add child view as subview [of parent]
        mainView.addSubview(viewController.view)
        
        // Configure child view
        viewController.view.frame = mainView.bounds
        viewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Notify the child view controller
        viewController.didMoveToParentViewController(self)
        
    }
    
    private func removeViewControllerAsChildViewController(viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMoveToParentViewController(nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    
    deinit{
        print(" (deinit) -> SegmentViewController")
    }
}