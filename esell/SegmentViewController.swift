//
//  SegmentViewController.swift
//  
//
//  Created by Angela Lin on 10/3/16.
//
//

import UIKit
import Firebase

enum Segment: Int {
    case table = 0
    case collection = 1
}

class SegmentViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var mainView: UIView!
    
    
    var posts = [ItemListing]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up segment control images and attach function
        setupSegmentControl()
        
        
        // Set up title
        self.navigationItem.title = "Browse Items"
        
        
        // Fetch data
        
        self.fetchPostsFromFirebase()
        
    }
    
    // MARK: functions
    
    func fetchPostsFromFirebase() {
        
        print("/n > running fetchPosts()...")
        
        let ref = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com/")
        
        ref.child("posts").observeEventType(.ChildAdded, withBlock: { (snapshot
            ) in
            
            print(snapshot)
            
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else {
                print("error unwrapping post")
                fatalError()
            }
            
            let post = ItemListing()
            
            post.title = dictionary["title"] as? String
            post.itemDescription = dictionary["description"] as? String
            post.price = dictionary["price"] as? String
            post.author = dictionary["author"] as? String
            post.imageURL = dictionary["image_url"] as? String
            
            // test print the date ...
            guard let postDate = dictionary["created_at"] as? NSTimeInterval else {
                print("error getting itme out")
                fatalError()
            }
            
            // Date conversion.. need to convert the NSTimeInterval and use timeIntervalSince1970 (do Not use timeIntervalSinceReferenceDate)
            post.createdDate = NSDate(timeIntervalSince1970: postDate/1000)
            
            let formatter = NSDateFormatter()
            //            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            //            formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            //            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            let rocCal = NSCalendar(calendarIdentifier: NSCalendarIdentifierRepublicOfChina)
            formatter.calendar = rocCal
            formatter.dateStyle = .FullStyle
            print(formatter.stringFromDate(post.createdDate!))
            
            print("postDate -> \(post.createdDate)")
            
            
            /// Hey do the image handling here ON A BACKGROUND THREAD SO IT"S NOT SLOW
            // get the image stuff out first as UIImage

            
            guard let url = NSURL(string: post.imageURL!),
            let imageData = NSData(contentsOfURL: url) else {
                print("error getting imageurl to nsurl")
                fatalError()
            }
            post.imageAsUIImage = UIImage(data: imageData)
            
            
            // PUT INTO LOCAL ARRAY
            self.tableViewController.posts.append(post)
            self.tableViewController.postCount += 1
            
            self.collectionViewController.posts.append(post)
            self.collectionViewController.postCount += 1
            
            print("new var postCount: \(self.tableViewController.postCount)")
            print("APPENDED in array. posts.count: \(self.tableViewController.posts.count)")
            
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionViewController.collectionView.reloadData()
                print("___reloaded")
                
            }

            
//            // Also put in the child view controllers' data array
//            
//            self.tableViewController.posts = self.posts
//            self.collectionViewController.posts = self.posts

     
            }, withCancelBlock: { (error) in
                print("fetchPosts error: \(error.localizedDescription)")
        })
        
    }
    
    
    func setupSegmentControl() {

        // attach function to segmentControl UI
        
        segmentControl.addTarget(self, action: #selector(setupSegmentSwitchView), forControlEvents: UIControlEvents.ValueChanged)
        

        // Set default segment that is Selected upon load
        
        segmentControl.selectedSegmentIndex = Segment.table.rawValue
        
        
        // initiate the lazy vars?
    
        setupSegmentSwitchView()
        
    }
    
    func setupSegmentSwitchView() {
        switch segmentControl.selectedSegmentIndex
        {
        case Segment.table.rawValue:
            print("blah 1")
            tableViewController.view.hidden = false
            collectionViewController.view.hidden = true
            
            
        case Segment.collection.rawValue:
            print("blah 2")
            tableViewController.view.hidden = true
            collectionViewController.view.hidden = false
            
            
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
        print(" >> Segment.mainview: just added table view controller")
        
        
        return viewController
        
    }()

    
    
    lazy var collectionViewController: ListingsCollectionViewController = {
        
        // Load storyboard
        
        let storyboard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
        
        // Instantiate view controller
        
        var viewController = storyboard.instantiateViewControllerWithIdentifier("ListingsCollectionViewController") as! ListingsCollectionViewController
        
        // Add this as a CHILD view controller
        
        self.addViewControllerAsChildViewController(viewController)
        print(" >> Segment.mainview: just added collection view controller")
        
        
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
        //(this means the var viewcontroller is the child view controller..., it passes 'self' which is the container view controller, as the argument)
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