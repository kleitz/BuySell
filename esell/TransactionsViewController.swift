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
    
    
    
    // for section/header
    var postsBuying = [ItemListing]()
    var myBids = [BidForItem]()
    
    // for each section/header cell
    var postsSelling = [ItemListing]()
    var otherBidsForMySale = [BidForItem]()
    
    let fireBase = FirebaseManager()
    
    
    enum Segment: Int {
        case postsBidOn = 0
        case postsCreated = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Get query from firebase
        // 1: list of things I've bidded for
        // 2: list of things I posted

        let currentUser = getUserID()
        
        
        // 1- fetch my bids
        fireBase.fetchBidsByUserID(userID: currentUser) { (bidsCreated) in
            
            
            // 1a -  this returns a list of my bids (but not posts)
            self.myBids = bidsCreated
            
            // 1b  - this returns a list that is for the PARENT POSTS of my bids
            
            for bid in self.myBids {
                
            
                print("SENDING THIS postiD \(bid.parentPostID)")
                
                // for each bid, look up the parent post so we can display post info in the table
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    self.fireBase.fetchSinglePostByPostID(postID: bid.parentPostID, withCompletionHandler: { (post) in
                        
                        print("post returned from handler: \(post.title)")
                        self.postsBuying.append(post)
                        
                        print("count of buyList . \(self.postsBuying.count)")
                        
                        dispatch_async(dispatch_get_main_queue()){
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
        
        // 2 - Fetch my posts
        
        fireBase.fetchPostsByUserID(userID: currentUser) { (postsCreated) in
            
            // 2a -  this returns a list of my created posts
            
            self.postsSelling = postsCreated
            
           // 2b - the bids for my posts.
            
            for post in self.postsSelling {
                
                print("sending this postID to get the child bids: \(post.id)")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    self.fireBase.fetchBidsByParentPost(postID: post.id, withCompletionHandler: { (bidsCreated) in
                        
                        if let bidsCreated = bidsCreated  {
                            self.otherBidsForMySale = bidsCreated
                            
                            print("count of other bids for my item: \(self.otherBidsForMySale.count)")
                            
                            dispatch_async(dispatch_get_main_queue()){
                                self.tableView.reloadData()
                            }

                        }
                        if bidsCreated == nil {
                        print("returned but there is no bids for this post")
                            
                        }
                        
                    })
                    
                }
                
                
            }

        }
        
        // TODO. Remove listeners in viewDidDisappear with a FirebaseHandle  - do need to remove event listener in this view???
        
        
        // 2 - Fetch my posts &
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        setupSegmentedControl()
        
        
        self.tableView.rowHeight = 90.0
        
        //self.tableView.tableHeaderView <- for fixed header, not sectino header?
        
        // ****** Do Step One for header custom view in tableview
        
        tableView.registerClass(HeaderViewCell.self, forHeaderFooterViewReuseIdentifier: "headerCell")
    
    }

    func setupSegmentedControl(){
        
        // attach function to segmentControl UI FOR WHEN VALUE CHANGED
        
        segmentedControl.addTarget(self, action: #selector(setupSegmentSwitchView), forControlEvents: UIControlEvents.ValueChanged)
        
        // set default selected index
        
        segmentedControl.selectedSegmentIndex = 0
        
    }
    
    func setupSegmentSwitchView() {
        
        
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.postsBidOn.rawValue:
            
            print("  > selected segment: BIDS")
            
            self.tableView.reloadData()
            
            
        case Segment.postsCreated.rawValue:
            
            print("  > selected segment: POSTS")

            self.tableView.reloadData()
            
            
        default: break }
    }
    
    
    // MARK - Table view functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var tableSourceArray = []
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.postsBidOn.rawValue:
            tableSourceArray = postsBuying
            //return buyList.count
            
            
        case Segment.postsCreated.rawValue:
            tableSourceArray = postsSelling
            //return sellList.count
            
        default: break
        }
        
        return tableSourceArray.count
    }
    
    
    // Table view SECTION/HEADER - [posts] go under here
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
 
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionHeaderReuseID = "headerCell"
        
        // ****** Do Step Two
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(sectionHeaderReuseID) as! HeaderViewCell
        
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.postsBidOn.rawValue:
            
            let postIBidOn = postsBuying[section]
            header.textLabel?.text = ("\(postIBidOn.title): \(postIBidOn.formattedPrice)")
            header.detailTextLabel?.text = postIBidOn.itemDescription
            
            
        case Segment.postsCreated.rawValue:
            
            let myPost = postsSelling[section]
            header.textLabel?.text = ("\(myPost.title): \(myPost.formattedPrice)")
            header.detailTextLabel?.text = myPost.itemDescription
            
        default: break }
        
        return header
        
    }
    
    
    // Table view CELLS - [bids] go under here. because each bid has a parent post
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 0
        
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.postsBidOn.rawValue:
            
            numberOfRows = self.postsBuying.count/self.myBids.count
            
            
        case Segment.postsCreated.rawValue:
            
            numberOfRows = self.otherBidsForMySale.count
            
        default: break }
        
        if numberOfRows != 0 {
            return numberOfRows
        } else {
            return 1
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        //
        
        let cell = tableView.dequeueReusableCellWithIdentifier("bodyCell", forIndexPath: indexPath) as! BodyCell
        
        
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.postsBidOn.rawValue:
            
            // use indexPath.section instead of indexPath.row for the bid because it's 1:1 relationship
            
            let postIBidOn = myBids[indexPath.section]
            
            cell.bidderNameLabel.text = ("My bid amount")
            cell.bidAmount.text = postIBidOn.formattedAmount
            
            // settings for UI hidden
            cell.bidAmount.hidden = false
            
            // hide the buttons in this case
            cell.acceptButton.hidden = true
            cell.rejectButton.hidden = true

            
        case Segment.postsCreated.rawValue:
            
            // if there is a bid for a particular section
            
            if otherBidsForMySale.count != 0 && indexPath.row == indexPath.section {
                
                
                let otherBid = otherBidsForMySale[indexPath.section]
                
                cell.bidderNameLabel.text = otherBid.bidderID
                cell.bidAmount.text = otherBid.formattedAmount
                
            } else {
                cell.bidderNameLabel.text = "You have no bids for this item"
                
                // settings for UI hidden
                cell.bidAmount.hidden = true
                
                // hide the buttons in this case
                cell.acceptButton.hidden = true
                cell.rejectButton.hidden = true
            }
            
        default: break }
 
        return cell
    }
    
    // Get user ID function
    
    func getUserID() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard let userID = defaults.stringForKey("uid") else {
            fatalError("failed getting nsuserdefaults uid")
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
