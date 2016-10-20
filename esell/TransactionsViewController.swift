//
//  TransactionsViewController.swift
//  esell
//
//  Created by Angela Lin on 10/14/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit



class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    enum Segment: Int {
        case postsBuying = 0
        case postsSelling = 1
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var containerView: UIView!
    
    
    // MARK: Data Variables
    
    weak var currentViewController: UITableViewController?
    
    // for section/header
    var postsBuying = [ItemListing]() { didSet { tableView.reloadData() } }
    var postsSelling = [ItemListing]() { didSet { tableView.reloadData() } }
    
    
    // for each section/header cell
    var myBids = [BidForItem]() { didSet { tableView.reloadData() } }
    var otherBidsForMySale = [[BidForItem]]() { didSet { tableView.reloadData() } }
    
    
    // create firebase instance
    
    let fireBase = FirebaseManager()
    
    ///var bidsDelegate: ?
    
    // MARK: View WILL Appear - data calling
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Get query from firebase
        // 1: list of things I've bidded for
        // 2: list of things I posted
        
        let currentUser = getUserID()
        print("\n [CURRENTUSER var]: \(currentUser)")
        
        // 1 - Fetch my bids
        fireBase.fetchBidsByUserID(userID: currentUser) { (bidsCreated) in
            
            
            // 1a -  this returns a list of my bids (but not posts)
            
            self.myBids = bidsCreated
            
            print("")
            print("NOTE~~(in fetchBids completion handler)~~ this should be where the myBids  is updated. ")
            
            
            
            
            ////print("\n__[1.lower][fetchBidsByUserID]  [myBids bidforItem].#count: \(self.myBids.count)")
            
            // 1b  - this returns a list that is for the PARENT POSTS of my bids
            
            for bid in self.myBids {
                
                ////print(" __[1.upper][fetchSinglePost]  Sending this bidID to get posts: \(bid.parentPostID)")
                
                // for each bid, look up the parent post so we can display post info in the table
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    self.fireBase.fetchSinglePostByPostID(postID: bid.parentPostID, withCompletionHandler: { (post) in
                        
                        print(" __[1.upper][fetchSinglePost]  -> 1 post returned from handler: \(post.title)")
                        self.postsBuying.append(post)
                        
                        print(" __[1.upper][fetchSinglePost]  -> appended now [post].#count: \(self.postsBuying.count)")
                        
                        
                        /// 1c Fetch user info out of each POST Set - requires another QUERY
                        // Then add returned info to local dictionary
                        
                        self.fireBase.fetchUserInfoFromFirebase(sellerUID: post.author, withCompletionHandler: { (getUser) in
                            
                            
                            print("~~~ in order for BUYSECTION try get userID:. sending this post.author: \(post.author)")
                            
                            // store this locally as the bidType's optional var
                            
                            bid.parentPostUserInfo = getUser
                            
                            //  reload after setting optional var in Bid
                            dispatch_async(dispatch_get_main_queue()) {
                                print("reloaded data")
                                self.tableView.reloadData()
                            }
                        })
                        
                    })
                }
            }
        }
        
        // 2 - Fetch my posts
        
        fireBase.fetchPostsByUserID(userID: currentUser) { (postsCreated) in
            
            // 2a -  this returns a list of my created posts
            
            self.postsSelling = postsCreated
            
            print("\n___[2.upper]_ [postsSelling array]: \(self.postsSelling.count)")
            
            // 2b - the bids for my posts.
            
            for post in self.postsSelling {
                
                print(" ___[2.upper]_ >> [fetchPostsByUserID] sending this postID to get bids: \(post.id)")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    self.fireBase.fetchBidsByParentPost(postID: post.id, withCompletionHandler: { (bidsArrayForOnePost) in
                        
                        self.otherBidsForMySale.append(bidsArrayForOnePost)
                        
                        
                        /// 2c Fetch user info out of each BID Set - requires another QUERY
                        // Then add returned info to local dictionary
                        
                        for eachBid in bidsArrayForOnePost {
                            
                            //TODO add conditional to prevent fetching for USERID="placeholder" (well.. it fails anyway so maybe it doesn't matter)
                            
                            self.fireBase.fetchUserInfoFromFirebase(sellerUID: eachBid.bidderID, withCompletionHandler: { (getUser) in
                                
                                
                                
                                // store this locally as the bidType's optional var
                                
                                eachBid.parentPostUserInfo = getUser
                                
                                // reload after setting optional var in Bid
                                dispatch_async(dispatch_get_main_queue()) {
                                    print("reloaded data")
                                    self.tableView.reloadData()
                                }
                                
                            })
                            
                        }
                        
                        print(" ___[2.upper]_ >> [fetchPostsByUserID] returned count, set to [2.lower][otherBidsForMySale]: \(self.otherBidsForMySale.count)")
                        
                    })
                }
            }
        }
        // TODO. Remove listeners in viewDidDisappear with a FirebaseHandle  - do need to remove event listener in this view???
    }
    // end of ViewWillAppear
    
    
    
    // MARK:  VIEW DID LOAD
    
    override func viewDidLoad() {
        
        self.currentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BuyingTableViewController") as! BuyingTableViewController
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.currentViewController!)
        self.addSubview(self.currentViewController!.view, toView: self.containerView)
        
        super.viewDidLoad()
        
        self.navigationItem.title = "My Offers"
        
        setupSegmentedControl()
        
        self.tableView.rowHeight = 90.0
        
        
    }
    
    
    
    
    
    // MARK: Table view functions.
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var tableSourceArray = []
        
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.postsBuying.rawValue:
            tableSourceArray = postsBuying
            
        case Segment.postsSelling.rawValue:
            tableSourceArray = postsSelling
            
        default: break
        }
        
        print(" ** number of SECTIONS for tablesourceArray: \(tableSourceArray.count)")
        
        return tableSourceArray.count
        
    }
    
    
    // Table view: SECTION/HEADER - [posts] go under here
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Create UIView from the custom nib
        
        let headerView = UINib(nibName: "SectionHeaderView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as!SectionHeaderView
        
        // Use autolayout resizing
        
        headerView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        
        
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.postsBuying.rawValue:
            
            let postIBidOn = postsBuying[section]
            
            headerView.titleLabel.text = postIBidOn.title
            headerView.priceLabel.text = postIBidOn.formattedPrice
            
            
        case Segment.postsSelling.rawValue:
            
            let myPost = postsSelling[section]
            
            // Only check if the 1st post is a placeholder, if it is, then the section info should be hidden
            guard let myFirstPost = postsSelling.first else {
                print("ERROR GETTING first post created")
                return headerView
            }
            
            if myFirstPost.id == "placeholder" {
                
                headerView.titleLabel.text = "You have no posts!"
                
                // TODO. need to set up quick functions for adjusting UI color and hiding and everything
                
                headerView.priceLabel.hidden = true
                
                
                // If the 1st post is not placeholder
            } else {
                
                headerView.titleLabel.text = myPost.title
                headerView.priceLabel.text = myPost.formattedPrice
                
                headerView.priceLabel.hidden = false
            }
            
            
        default: break }
        
        
        return headerView
        
    }
    
    
    // Table view: CELLS - [bids] go under here. because each bid has a parent post
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 0
        
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.postsBuying.rawValue:
            
            print("[1.lower]postsBidOn section#: \(section). ")
            
            
            // when is this not 1? I can only bid once for another person's post.
            
            numberOfRows = 1
            
            
        case Segment.postsSelling.rawValue:
            
            print("[2.lower] bidsForCreatedPost section##: \(section). BIGarrayCOunt: \(otherBidsForMySale.count). InnerArrayCount: \(otherBidsForMySale[section].count) ")
            
            if self.postsBuying.count != 0 && self.otherBidsForMySale.count != 0 {
                
                numberOfRows = self.otherBidsForMySale[section].count
                
            }
            
        default: break }
        
        return numberOfRows
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("bodyCell", forIndexPath: indexPath) as! BodyCell
        
        
        // settings for UI hide/show
        self.setupUIForCell(cell)
        
        
        
        switch segmentedControl.selectedSegmentIndex {
            
            
        case Segment.postsBuying.rawValue:
            
            
            // use indexPath.section instead of indexPath.row for the bid because it's 1:1 relationship
            // MARK: Buying section: must exist. show my 1 bid under parent post
            
            let postIBidOn = myBids[indexPath.section]
            
            cell.buyingSectionPriceAmount.text = ""
            //("Made an offer of \(postIBidOn.formattedAmount).")actually don't need this in the above label.. assume same price
            
            // Add conditional for when bid is responded to and/or accepted
            
            /// if the bid is open
            
            
            if myBids[indexPath.section].isRespondedBySeller {
                
                if myBids[indexPath.section].isAcceptedBySeller {
                
                print("~~ MY BID WAS ACCEPTED")
                cell.buyingSectionStatus.text = "has ACCEPTED YOUR OFFER!"
                cell.buyingSectionStatus.textColor = UIColor.darkTextColor()
                    
                } else {
                    
                    print("~~ MY BID WAS REJECTED")
                    cell.buyingSectionStatus.text = "has declined your offer"
                    cell.buyingSectionStatus.textColor = UIColor.darkTextColor()
                    
                }
                
                
                
            } else {
            
            /// if the bid is closed/responded. everything should still show, except for the button status
            
            cell.buyingSectionStatus.text = "no response yet"
            cell.buyingSectionStatus.textColor = UIColor.lightGrayColor()
            
            }
            
            // Set seller profile iamage
            
            // print("~~~ BUYSECTION getting userID from async local var: #\(indexPath.row):: \(postsBuying[indexPath.row].author) print\(postIBidOn.parentPostUserInfo?.imageURL)\n ")
            
            if let userCompleteFromBid: User = postIBidOn.parentPostUserInfo {
                
                cell.buyingSectionUserName.text = userCompleteFromBid.name
                
                
                // Start URL request for profile image in background thread
                
                let profileURL = userCompleteFromBid.imageURL
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    if let url = NSURL(string: profileURL) {
                        
                        // Download an NSData representation of the image at the URL
                        let urlRequest = NSURLRequest(URL: url)
                        
                        let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
                            if error == nil {
                                
                                guard let unwrappedData = data else {
                                    print("Error converting image")
                                    return
                                }
                                
                                guard let image = UIImage(data: unwrappedData) else {
                                    print("Error converting image")
                                    return
                                }
                                
                                // Display image (using main thread
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    
                                    cell.buyingSectionUserImage.image = image
                                    cell.buyingSectionUserImage.contentMode = .ScaleAspectFill
                                    
                                    self.roundUIView(cell.buyingSectionUserImage, cornerRadiusParams: cell.buyingSectionUserImage.frame.size.width / 2)
                                    
                                })
                                
                            } else {
                                
                                print(error?.localizedDescription)
                            }
                        })
                        
                        task.resume()
                    }
                }
            }
            
        case Segment.postsSelling.rawValue:
            
            
            
            
            guard let myFirstPost = postsSelling.first else {
                print("ERROR GETTING first post created")
                return cell
            }
            
            // MARK: Selling section: case1. I have no posts to show.
            
            // Because if there is an empty query for post then it will return "placeholder" id
            
            if myFirstPost.id == "placeholder" {
                
                cell.sellingSectionUserName.text = "" //message can go here but I put it in the header
                
                
                
                // If the 1st post is not placeholder then continue showing data on UI
                
            } else {
                
                
                let bidsForOnePost = otherBidsForMySale[indexPath.section][indexPath.row]
                
                // MARK: Selling section: case2. I have posts but no bids for my post.
                
                // If the bids is a placeholder, then return message
                
                if bidsForOnePost.bidID == "placeholder" {
                    cell.sellingSectionUserName.text = "You have no bids for this item"
                    
                    // UI settings NOTE: HAS plus special additional ones because NO RESPONSE SO HIDE A LOT OF STUFF
                    
                    cell.acceptButton.hidden = true
                    cell.sellingSectionPriceAmount.text = ""
                    cell.sellingSectionStatusImage.hidden = true
                    cell.sellingSectionUserImage.hidden = true
                    
                }
                    
                    // MARK: Selling section: case3. I have posts and there are bids for my post.
                    // Else if bids exist for a particular section then return the BID INFO
                    
                else {
                    
                    
                    // set up UI
                    
                    cell.sellingSectionPriceAmount.text = bidsForOnePost.formattedAmount
                    
                    cell.sellingSectionStatusImage.contentMode = .ScaleAspectFill
                    
                    if bidsForOnePost.isPaidOnline {
                        cell.sellingSectionStatusImage.image = UIImage(named: "crediticon")
                    } else  {
                        cell.sellingSectionStatusImage.image = UIImage(named: "cashicon")
                    }
                    
                    
                    // stuff that requires querying for user from bidder_id: NAME, PROFILE PIC..
                    
                    if let userCompleteFromBid: User = bidsForOnePost.parentPostUserInfo {
                        
                        cell.sellingSectionUserName.text = userCompleteFromBid.name
                        
                        
                        // Start URL request for profile image in background thread
                        
                        let profileURL = userCompleteFromBid.imageURL
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                            
                            if let url = NSURL(string: profileURL) {
                                
                                // Download an NSData representation of the image at the URL
                                let urlRequest = NSURLRequest(URL: url)
                                
                                let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
                                    if error == nil {
                                        
                                        guard let unwrappedData = data else {
                                            print("Error converting image")
                                            return
                                        }
                                        
                                        guard let image = UIImage(data: unwrappedData) else {
                                            print("Error converting image")
                                            return
                                        }
                                        
                                        // Display image (using main thread
                                        
                                        dispatch_async(dispatch_get_main_queue(), {
                                            
                                            cell.sellingSectionUserImage.image = image
                                            cell.sellingSectionUserImage.contentMode = .ScaleAspectFill
                                            
                                            self.roundUIView(cell.sellingSectionUserImage, cornerRadiusParams: cell.sellingSectionUserImage.frame.size.width / 2)
                                            
                                        })
                                        
                                    } else {
                                        
                                        print(error?.localizedDescription)
                                    }
                                })
                                
                                task.resume()
                            }
                        }//end of dispatch_async
                    } // end of using local var to fill UserData
                    
                    
                    
                    // Add conditional for when bid is responded to and/or accepted
                    
                    /// if the bid is open
                    
                    
                    if bidsForOnePost.isRespondedBySeller == false {
                        
                        // attach function for button acceptBid
                        
                        cell.acceptButton.addTarget(self, action: #selector(acceptBid(_:)), forControlEvents: .TouchUpInside)
                        
                        // set up all UI colors & text for this case
                        
                        cell.acceptButton.backgroundColor = UIColor(red: 143.0/255, green: 190.0/255, blue: 0/255, alpha: 1.0)
                        cell.acceptButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                        cell.acceptButton.setTitle("Accept Offer", forState: .Normal)
                        cell.acceptButton.enabled = true
                        
                        
                    }
                        
                        /// if the bid is closed/responded. everything should still show, except for the button status
                        
                    else {
                        
                        // set up all UI colors for this case
                        
                        cell.acceptButton.enabled = false
                        
                        cell.acceptButton.backgroundColor = UIColor.whiteColor()
                        
                        if bidsForOnePost.isAcceptedBySeller {
                            
                            // set up the text for this case
                            
                            cell.acceptButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                            cell.acceptButton.setTitle("accepted", forState: .Normal)
                            
                        } else {
                            
                            // set up the text for this case
                            
                            cell.acceptButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
                            cell.acceptButton.setTitle("not accepted", forState: .Normal)
                        }
                        
                        
                    }
                }
                
            }
        default: break }
        
        return cell
    }
    
    
    // MARK: Other functions
    
    // Get user ID function
    
    func getUserID() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard let userID = defaults.stringForKey("uid") else {
            fatalError("failed getting nsuserdefaults uid")
        }
        
        return userID
    }
    
    
    // for image rounding for the button in tableView for accepting bid
    
    private func roundUIView(view: UIView, cornerRadiusParams: CGFloat!) {
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadiusParams
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
    
    
    // MARK: Function to Accept Bid & confirm. UIAlertController
    
    
    func acceptBid(sender: UIButton) {
        
        print("clicked accept")
        
        guard let senderCell = sender.superview?.superview as? UITableViewCell,
            cellIndexPath = tableView?.indexPathForCell(senderCell) else {
                fatalError()
        }
        
        
        let acceptedBid = self.otherBidsForMySale[cellIndexPath.section][cellIndexPath.row]
        
        // print("cellindexpath : \(cellIndexPath.row).\n   accepted bid?? \(acceptedBid.amount) \n    person bidding?? \(acceptedBid.parentPostUserInfo?.name)")
        
        popupConfirmToAcceptBid(bid: acceptedBid)
        
    }
    
    func popupConfirmToAcceptBid(bid acceptedBid: BidForItem) {
        
        let alertController = UIAlertController(title: "Accept this bid?", message:
            "You can only accept 1 bid for your post", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        
        let cancelOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print(" > clicked cancel save")
            
        })
        
        let confirmSaveOption = UIAlertAction(title: "Accept Bid", style: UIAlertActionStyle.Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            print(" > clicked CONFIRM SAVE BID")
            
            // do save
            self.fireBase.updateAllBidsOfOnePost(parentPostID: acceptedBid.parentPostID, acceptedBidID: acceptedBid.bidID) { (isUpdated) in
                if isUpdated == true {
                    
                    print("TransctionViewControler: firebase completetionhalder ---> UPDATED DB")
                    
                    self.tableView.reloadData()
                    
                    // TODO need to write the conditionals for changing cell UI
                }
            }
            
            
            // notify it's saved w/ popup
            
            self.popupNotifyPosted()
            
        })
        
        alertController.addAction(confirmSaveOption)
        alertController.addAction(cancelOption)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func popupNotifyPosted(){
        
        let alertController = UIAlertController(title: "Bid Accepted", message:
            "Your buyer is notified - contact them to set up your delivery!", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
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
            
            // set seller
            
            self.tableView.reloadData()
            
            // set container view content
            
            let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("BuyingTableViewController") as! BuyingTableViewController
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
            self.currentViewController = newViewController
            
            
        case Segment.postsSelling.rawValue:
            
            print("  > selected segment: POSTS")
            

            self.tableView.reloadData()
            
            
            let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SellingTableViewController") as! SellingTableViewController
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
            self.currentViewController = newViewController
            
        default: break }
    }
    
    
    func setupUIForCell(cell: BodyCell) {
        
        switch segmentedControl.selectedSegmentIndex {
            
        case Segment.postsBuying.rawValue:
            
            cell.sellingSectionUserName.hidden = true
            cell.sellingSectionUserImage.hidden = true
            cell.sellingSectionPriceAmount.hidden = true
            cell.sellingSectionStatusImage.hidden = true
            cell.acceptButton.hidden = true
            
            
            cell.buyingSectionUserName.hidden = false
            cell.buyingSectionUserImage.hidden = false
            cell.buyingSectionPriceAmount.hidden = false
            cell.buyingSectionStatus.hidden = false
            cell.buyingSectionStatusImage.hidden = false
            
            
            
        case Segment.postsSelling.rawValue:
            
            cell.sellingSectionUserName.hidden = false
            cell.sellingSectionUserImage.hidden = false
            cell.sellingSectionPriceAmount.hidden = false
            cell.sellingSectionStatusImage.hidden = false
            cell.acceptButton.hidden = false
            
            cell.buyingSectionUserName.hidden = true
            cell.buyingSectionUserImage.hidden = true
            cell.buyingSectionPriceAmount.hidden = true
            cell.buyingSectionStatus.hidden = true
            cell.buyingSectionStatusImage.hidden = true
            
            
        default: break
            
        }
    }
    
    
}
