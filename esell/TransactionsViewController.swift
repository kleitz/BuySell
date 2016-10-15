//
//  TransactionsViewController.swift
//  esell
//
//  Created by Angela Lin on 10/14/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var bidList = [BidForItem]()
    
    var buyList = [ItemListing]()
    
    var sellList = [ItemListing]()
    
    let fireBase = FirebaseManager()
    
    
    enum Segment: Int {
        case myBiddedPosts = 0
        case myCreatedPosts = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Get query from firebase
        // 1: list of things I've bidded for
        // 2: list of things I posted

        let currentUser = getUserID()
        
        fireBase.fetchBidsByUserID(userID: currentUser) { (bidsCreated) in
            
            
            // this returns a list of bids (but not posts)
            self.bidList = bidsCreated
            
            // this returns a list that is for the PARENT POSTS
            
            for item in self.bidList {
                
            
                print("SENDING THIS postiD \(item.parentPostID)")
                
                // for each bid, look up the parent post so we can display post info in the table
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    self.fireBase.fetchSinglePostByPostID(postID: item.parentPostID, withCompletionHandler: { (post) in
                        
                        print("post returned from handler: \(post.title)")
                        self.buyList.append(post)
                        
                        print("count of buyList . \(self.buyList.count)")
                        
                        dispatch_async(dispatch_get_main_queue()){
                            self.tableView.reloadData()
                        }
                        
                        
                    })
                    
                }
                
            }
            
        }
        
        fireBase.fetchPostsByUserID(userID: currentUser) { (postsCreated) in
            
            self.sellList = postsCreated

        }
        
        // TODO. Remove listeners in viewDidDisappear with a FirebaseHandle  - do need to remove event listener in this view???
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegmentedControl()
    
    }

    func setupSegmentedControl(){
        
        // attach function to segmentControl UI FOR WHEN VALUE CHANGED
        
        segmentedControl.addTarget(self, action: #selector(setupSegmentSwitchView), forControlEvents: UIControlEvents.ValueChanged)
        
        // set default selected index
        
        segmentedControl.selectedSegmentIndex = 0
        
    }
    
    func setupSegmentSwitchView() {
        
        
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.myBiddedPosts.rawValue:
            
            print("  > selected segment: BIDS")
            
            self.tableView.reloadData()
            
            
        case Segment.myCreatedPosts.rawValue:
            
            print("  > selected segment: POSTS")

            self.tableView.reloadData()
            
            
        default: break }
    }
    
    
    // MARK - Table view functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var tableSourceArray = []
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.myBiddedPosts.rawValue:
            tableSourceArray = buyList
            //return buyList.count
            
            
        case Segment.myCreatedPosts.rawValue:
            tableSourceArray = sellList
            //return sellList.count
            
        default: break
        }

        return tableSourceArray.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.myBiddedPosts.rawValue:
            
            let postIBidOn = buyList[indexPath.row]
            cell.textLabel?.text = postIBidOn.title
            cell.detailTextLabel?.text = postIBidOn.itemDescription
            
            
        case Segment.myCreatedPosts.rawValue:
            
            let myPost = sellList[indexPath.row]
            cell.textLabel?.text = myPost.title
            cell.detailTextLabel?.text = myPost.itemDescription
            
        default: break }
 
        return cell
    }
    
    // Get user ID function
    
    func getUserID() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard let userID = defaults.stringForKey("uid") else {
            print("failed getting nsuserdefaults uid")
            return ""
        }
        
        return userID
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
