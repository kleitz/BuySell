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
    

    // MARK: Data Variables
    
    // for section/header
    var postsBuying = [ItemListing]() { didSet { tableView.reloadData() } }
    var postsSelling = [ItemListing]() { didSet { tableView.reloadData() } }
    
    
    // for each section/header cell
    var myBids = [BidForItem]() { didSet { tableView.reloadData() } }
    var otherBidsForMySale = [[BidForItem]]() { didSet { tableView.reloadData() } }
    
    // create a user array/dict? to store ANY user info
    var UserInfoDictionary = [String:User]() { didSet { tableView.reloadData() } }
    
    
    
    let fireBase = FirebaseManager()

    
    
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
            print("\n__[1.lower]__ [bidsCreated array]: \(self.myBids.count)")
            
            // 1b  - this returns a list that is for the PARENT POSTS of my bids
            
            for bid in self.myBids {
                
                print(" __[1.upper]__ [fetchBidsByUserID] Sending this bidID to get posts: \(bid.parentPostID)")
                
                // for each bid, look up the parent post so we can display post info in the table
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    self.fireBase.fetchSinglePostByPostID(postID: bid.parentPostID, withCompletionHandler: { (post) in
                        
                        print(" __[1.upper]__  -> post returned from handler: \(post.title)")
                        self.postsBuying.append(post)
                        
                        print(" __[1.upper]__-> [fetchBidsByUserID] returned count of posts, set to [postsBuying]: \(self.postsBuying.count)")

                        
                        /// 1c Fetch user info out of each POST Set - requires another QUERY
                        // Then add returned info to local dictionary
                        
                        self.fireBase.fetchUserInfoFromFirebase(sellerUID: post.author, withCompletionHandler: { (getUser) in
                            
                            
                            print("~~~ in order for BUYSECTION try get userID:. sending this post.author: \(post.author)")
                            
                            // store this locally as the bidType's optional var
                            
                            bid.parentPostUserInfo = getUser
                            
                            // reload after setting optional var in Bid
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
                                
                                
                                // store in dictionary? TODO.not needd if used class. remove later?
                                
                                self.UserInfoDictionary.updateValue(getUser, forKey: eachBid.bidderID)
                                
                                
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
        
        super.viewDidLoad()
        
        self.navigationItem.title = "My Offers"
        
        setupSegmentedControl()
        
        self.tableView.rowHeight = 90.0
    
        
    }

    

    
    
    // MARK: Table view functions
    
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
        
        
        // SWITCH CASE
            switch segmentedControl.selectedSegmentIndex {
                
            case Segment.postsBuying.rawValue:
                
                
                // use indexPath.section instead of indexPath.row for the bid because it's 1:1 relationship
                
                let postIBidOn = myBids[indexPath.section]
                
                cell.buyingSectionPriceAmount.text = ""
                //("Made an offer of \(postIBidOn.formattedAmount).")actually don't need this in the above label.. assume same price
                
                
                // Set seller profile iamage
                
                print("~~~ BUYSECTION getting userID from async local var: #\(indexPath.row):: \(postsBuying[indexPath.row].author) print\(postIBidOn.parentPostUserInfo?.imageURL)\n ")
                
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
                
                // If there is an empty query then it will return "placeholder" id for the post
                
                // Only check if the 1st post is a placeholder
                guard let myFirstPost = postsSelling.first else {
                    print("ERROR GETTING first post created")
                    return cell
                }
                
                if myFirstPost.id == "placeholder" {
                    
                    cell.sellingSectionUserName.text = "" //message can go here but I put it in the header
                    

                    // If the 1st post is not placeholder
                } else {
                    
                    let bidsForOnePost = otherBidsForMySale[indexPath.section][indexPath.row]
                    
                    // If the bids is a placeholder, then return message
                    
                    if bidsForOnePost.bidID == "placeholder" {
                        cell.sellingSectionUserName.text = "You have no bids for this item"

                        // UI settings NOTE: HAS plus special additional ones because NO RESPONSE SO HIDE A LOT OF STUFF
                        
                        cell.acceptButton.hidden = true
                        cell.sellingSectionPriceAmount.text = ""
                        cell.sellingSectionStatusImage.hidden = true
                        cell.sellingSectionUserImage.hidden = true
                        
                    }
                        
                        
                        // Else if bids exist for a particular section then return the BID INFO
                        
                    else {
                        
                        // set up button functions acceptBid
                        
                        cell.acceptButton.addTarget(self, action: #selector(acceptBid(_:)), forControlEvents: .TouchUpInside)
                        
                        
                        // set up other stuff
                        
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
    

    
    
    // for image rounding
    
    private func roundUIView(view: UIView, cornerRadiusParams: CGFloat!) {
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadiusParams
    }

    
    // for the button in tableView for accepting bid
    
    
    // OTHER FUNCS
    
    func acceptBid(sender: UIButton) {
        
        print("clicked accept")
        
        guard let senderCell = sender.superview?.superview as? UITableViewCell,
            cellIndexPath = tableView?.indexPathForCell(senderCell) else {
                fatalError()
        }
        
       
        let acceptedBid = self.otherBidsForMySale[cellIndexPath.section][cellIndexPath.row]

        // print("cellindexpath : \(cellIndexPath.row).\n   accepted bid?? \(acceptedBid.amount) \n    person bidding?? \(acceptedBid.parentPostUserInfo?.name)")
        
        popupNotifyPosted()

        fireBase.updateAllBidsOfOnePost(parentPostID: acceptedBid.parentPostID, acceptedBidID: acceptedBid.bidID) { (isUpdated) in
            if isUpdated == true {
                
                print("TransctionViewControler: firebase completetionhalder ---> UPDATED DB")
                
                self.tableView.reloadData()
                
                // TODO need to write the conditionals
            }
        }
        
        
        
    }
    

    func popupNotifyPosted(){
        
        let alertController = UIAlertController(title: "Accept Complete", message:
            "Your buyer is notified - contact them to set up delivery!", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
//    
//    func confirmUpdateBid(){
//        
//        // after the popup, it should save the accepted as TRUE and set all the others ones as false
//                    // 1) look up postID. get all the bids. set all the bids as CLOSED. with the only 1 bid as accept = true
//        
//        
//    }
//    
    
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
            
            
        case Segment.postsSelling.rawValue:
            
            print("  > selected segment: POSTS")
            
            
            
            self.tableView.reloadData()
            
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
