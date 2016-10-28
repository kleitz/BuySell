//
//  SellingTableViewController.swift
//  esell
//
//  Created by Angela Lin on 10/20/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class SellingTableViewController: UITableViewController {
    
    
    // MARK: Data Variables
    
    // for section/header
    var sectionPostsArray = [ItemListing]() //{ didSet { tableView.reloadData() } }
    
    // for each section/header cell
    var cellBidsArray = [[BidForItem]]() //{ didSet { tableView.reloadData() } }
    
    let fireBase = FirebaseManager()
    
    
    
    // MARK: - Lifecycle ViewWillAPPEAR
    override func viewWillAppear(animated: Bool) {
        print("\n >> View WILL APPEAR.")
        
        super.viewWillAppear(animated)
        
        print("count of array(posts): \(sectionPostsArray.count)")
        print("count of array(bids): \(cellBidsArray.count)")
        
        let currentUser = getUserID()
        
        // 2 - Fetch my posts
        
        fireBase.fetchPostsByUserID(userID: currentUser) { (postsCreated) in
            // 2a -  this returns a list of my created posts
            
            self.sectionPostsArray = postsCreated
            
            print("\n___[2.upper]_ [postsSelling array]: \(self.sectionPostsArray.count)")
            
            // 2b - the bids for my posts.
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                self.fireBase.fetchBidsByPostArray(postsCreated: postsCreated, withCompletionHandler: { (bidsArrayForOnePost) in
                    
                    print("IN COMPLETION HANDLER FOR BIDS (for cell display")
                    
                    self.cellBidsArray.append(bidsArrayForOnePost)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        print(" ---- reloaded data")
                        self.tableView.reloadData()
                    }
                    
                    for bid in bidsArrayForOnePost {
                        // get the parent post info for each bid here
                        
                        self.fireBase.lookupSingleUser(userID: bid.bidderID, withCompletionHandler: { (getUser) in
                            bid.parentPostUserInfo = getUser
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                print(" 2---- reloaded data")
                                self.tableView.reloadData()
                            }
                        })
                    }
                })
            }
            
        }
    }
    
    
    
    // MARK: Lifecycle ViewDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(" >> ViewDidLoad. sellingTable loaded ")
        
        self.tableView.rowHeight = 70.0
        
        // Remove table view seperator lines
        tableView.separatorStyle = .None
        
    }
    
    // MARK: Lifecycle ViewWillDISAPPEAR
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print(" >> sellingTable is disappearing... removing observers ")
        fireBase.ref.removeAllObservers()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return sectionPostsArray.count
    }
    
    
    // Table view: SECTION/HEADER - [posts] go under here
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Create UIView from the custom nib
        
        let headerView = UINib(nibName: "SectionHeaderView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! SectionHeaderView
        
        headerView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        
        // Get Posts info to load in header
        
        let myPost = sectionPostsArray[section]
        
        
        // Only check if the 1st post is a placeholder, if it is, then the section info should be hidden
        
        guard let myFirstPost = sectionPostsArray.first else {
            print("ERROR GETTING first post created")
            // TODO probably should fix this better
            fatalError()
        }
        
        
        // MARK: Selling section: case1. you haven't created any posts.
        
        if myFirstPost.id == "placeholder" {
            
            headerView.titleLabel.text = "You have no posts!"
            
            // TODO. need to set up quick functions for adjusting UI color and hiding and everything
            
            headerView.priceLabel.hidden = true

            return headerView
        }
        
        
        // If the 1st post is not placeholder then...
        // MARK: Selling section: case2. I have posts and may/maynot have bids for the posts.
        
        headerView.titleLabel.text = myPost.title
        headerView.priceLabel.hidden = true
        headerView.priceLabel.text = myPost.formattedPrice

        // headerView.priceLabel.hidden = false
        
        return headerView
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 0
        
        print("in section#: \(section)")
        print("OUterArrayCOunt: \(cellBidsArray.count)")
        
        // in case not all data has returned, numberOfRows = 1
        if cellBidsArray.count != sectionPostsArray.count {
            numberOfRows = 1
            return numberOfRows
        }
        
        numberOfRows = self.cellBidsArray[section].count

        return numberOfRows
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("sellCell", forIndexPath: indexPath) as! SellTableViewCell
        
        setDefaultCellUI(cell, isHiddenExceptName: true)

        print(" **  > in tableview cellforRow: section\(indexPath.section): row\(indexPath.row)")
        
        // MARK: Selling section: case1. you haven't created any posts.
        
        guard let myFirstPost = sectionPostsArray.first else {
            print("ERROR GETTING first post created")
            // TODO probably should fix this better
            fatalError()
        }
        if myFirstPost.id == "placeholder" {
            
            print("    > in tableview cellforRow: ____ no posts exist")
            
            cell.userName.text = "" // TODO Custom message for having no posts
            
            return cell
        }
        
        
        // MARK: Selling section: case2. I have posts but no bids for my post.
        
        // in case bids (data for cells) hasn't returned yet
        
        else if cellBidsArray.count != sectionPostsArray.count {
            
            print("    > in tableview cellforRow: _____ bids not returned yet")
            
            cell.userName.text = "No bids yet for this item!"
            
            return cell
            
        }
        
        
        let bidsForOnePost = cellBidsArray[indexPath.section][indexPath.row]
        
        // If the bids is a placeholder, then return message
        
        if bidsForOnePost.bidID == "placeholder" {
            
            print("    > in tableview cellforRow: _____ no bids for posts")

            cell.userName.text = "You have no bids for this item"
        }
            
        // MARK: Selling section: case3. I have posts and there are bids for my post.
            // Else if bids exist for a particular section then return the BID INFO
            
        else {
            
            // Show/hide UI stuff
            
            setDefaultCellUI(cell, isHiddenExceptName: false)
            
            // Set up UI

            cell.offerAmount.text = bidsForOnePost.formattedAmount
            cell.offerPaymentImage.contentMode = .ScaleAspectFill
            
            cell.userName.text = bidsForOnePost.parentPostUserInfo?.name
            
            switch bidsForOnePost.isPaidOnline {
            case true:
                cell.offerPaymentImage.image = UIImage(named: "crediticon")
            case false:
                cell.offerPaymentImage.image = UIImage(named: "cashicon")
            }
            
            
            // stuff that requires querying for user from bidder_id: NAME, PROFILE PIC..
            
            if let userCompleteFromBid: User = bidsForOnePost.parentPostUserInfo {
                
                cell.userName.text = userCompleteFromBid.name
                
                
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
                                    
                                    cell.userImage.image = image
                                    cell.userImage.contentMode = .ScaleAspectFill
                                    
                                    self.roundUIView(cell.userImage, cornerRadiusParams: cell.userImage.frame.size.width / 2)
                                })
                                
                            } else {
                                
                                print(error?.localizedDescription)
                            }
                        })
                        task.resume()
                    }
                } //end of dispatch_async
            } // end of using local var to fill UserData
            
            
            
            // Switch/case for if you have already responded to the bid for your post
            
            switch bidsForOnePost.isRespondedBySeller {
                
            case false:
                // attach function for button acceptBid
                
                cell.acceptOfferButton.addTarget(self, action: #selector(acceptBid(_:)), forControlEvents: .TouchUpInside)
                
                // set up UI for responded=false
                
                cell.acceptOfferButton.enabled = true
                
                cell.acceptOfferButton.backgroundColor = UIColor(red: 143.0/255, green: 190.0/255, blue: 0/255, alpha: 1.0)
                
                cell.acceptOfferButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                cell.acceptOfferButton.setTitle("Accept Offer", forState: .Normal)
                
                
            case true:
                
                // set up UI for responded=true
                
                cell.acceptOfferButton.enabled = false
                
                cell.acceptOfferButton.backgroundColor = UIColor.whiteColor()
                
                
                switch bidsForOnePost.isAcceptedBySeller {
                    // IF You have responded AND whether accepted/rejected
                    
                case true:
                    
                    cell.acceptOfferButton.setTitle("accepted!", forState: .Normal)
                    cell.acceptOfferButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
                    
                    
                case false:
                    
                    cell.acceptOfferButton.setTitle("not accepted", forState: .Normal)
                    cell.acceptOfferButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
                    
                }
                
            }
        }
        
        return cell
    }
    
    // MARK: - Other
    
    deinit {
        print("[DEINIT] SellingTable was killed")
        
    }

    
    // MARK: Function to Accept Bid & confirm. UIAlertController
    
    
    func acceptBid(sender: UIButton) {
        
        print("clicked accept")
        
        guard let senderCell = sender.superview?.superview as? UITableViewCell,
            cellIndexPath = tableView?.indexPathForCell(senderCell) else {
                fatalError()
        }
        
        
        let acceptedBid = self.cellBidsArray[cellIndexPath.section][cellIndexPath.row]
        
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
            self.fireBase.updateAllBidsOfOnePost(parentPostID: acceptedBid.parentPostID, acceptedBidID: acceptedBid.bidID, withCompletionHandler:  { (isUpdated) in
                if isUpdated == true {
                    
                    print("TransctionViewControler: firebase completetionhalder ---> UPDATED DB")
                    
                    acceptedBid.parentPostInfo?.isOpen = false
                    
                    print("----- \(acceptedBid.parentPostInfo?.isOpen)")
                    //                    self.fireBase.fetchPostsForBrowse()
                    
                    self.tableView.reloadData()
                    
                    // TODO need to write the conditionals for changing cell UI
                }
            })
            
            
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
    
    private func setDefaultCellUI(cell: SellTableViewCell, isHiddenExceptName isHidden: Bool) {
        
        cell.userImage.hidden = isHidden
        cell.acceptOfferButton.hidden = isHidden
        cell.offerAmount.hidden = isHidden
        cell.offerPaymentImage.hidden = isHidden
        
    }
    
    
    // for image rounding for the button in tableView for accepting bid
    
    private func roundUIView(view: UIView, cornerRadiusParams: CGFloat!) {
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadiusParams
    }
    
    
    // Get user ID function
    
    private func getUserID() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard let userID = defaults.stringForKey("uid") else {
            fatalError("failed getting nsuserdefaults uid")
        }
        return userID
    }
    
}
