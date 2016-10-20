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
        
        super.viewWillAppear(animated)
        
        
        let currentUser = getUserID()
        
        // 2 - Fetch my posts
        
        fireBase.fetchPostsByUserID(userID: currentUser) { (postsCreated) in
            
            // 2a -  this returns a list of my created posts
            
            self.sectionPostsArray = postsCreated
            
            print("\n___[2.upper]_ [postsSelling array]: \(self.sectionPostsArray.count)")
            
            // 2b - the bids for my posts.
            
            for post in self.sectionPostsArray {
                
                print(" ___[2.upper]_ >> [fetchPostsByUserID] sending this postID to get bids: \(post.id)")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    self.fireBase.fetchBidsByParentPost(postID: post.id, withCompletionHandler: { (bidsArrayForOnePost) in
                        
                        self.cellBidsArray.append(bidsArrayForOnePost)
                        
                        
                        /// 2c Fetch user info out of each BID Set - requires another QUERY
                        // Then add returned info to local dictionary
                        
                        for eachBid in bidsArrayForOnePost {
                            
                            //TODO add conditional to prevent fetching for USERID="placeholder" (well.. it fails anyway so maybe it doesn't matter)
                            
                            self.fireBase.fetchUserInfoFromFirebase(sellerUID: eachBid.bidderID, withCompletionHandler: { (getUser) in
                                
                                
                                // store this locally as the bidType's optional var
                                
                                eachBid.parentPostUserInfo = getUser
                                
                                 //reload after setting optional var in Bid
                                                                dispatch_async(dispatch_get_main_queue()) {
                                                                    print("reloaded data")
                                                                    self.tableView.reloadData()
                                                                }
                                
                            })
                            
                        }
                        //
                        //                        print(" ___[2.upper]_ >> [fetchPostsByUserID] returned count, set to [2.lower][otherBidsForMySale]: \(self.otherBidsForMySale.count)")
                        //
                    })
                }
            }
        }
        // TODO. Remove listeners in viewDidDisappear with a FirebaseHandle  - do need to remove event listener in this view???
        
        
    }
    
    
    
    // MARK: Lifecycle ViewDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(" >> sellingTable loaded ")
        
        self.tableView.rowHeight = 70.0
        
    }
    
    // MARK: Lifecycle ViewWillDISAPPEAR
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print(" >> sellingTable is disappearing... removing observers ")
        fireBase.ref.removeAllObservers()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionPostsArray.count
    }
    
    
    // Table view: SECTION/HEADER - [posts] go under here
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Create UIView from the custom nib
        
        let headerView = UINib(nibName: "SectionHeaderView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! SectionHeaderView
        
        // Use autolayout resizing
        
        headerView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        
        
        // Get Posts info to load in header
        
        let myPost = sectionPostsArray[section]
        
        // Only check if the 1st post is a placeholder, if it is, then the section info should be hidden
        
        
        
        guard let myFirstPost = sectionPostsArray.first else {
            print("ERROR GETTING first post created")
            // TODO probably should fix this better
            fatalError()
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
        
        
        return headerView
        
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 0
        
//        print("in section#: \(section). OUterArrayCOunt: \(cellBidsArray.count). InnerArrayCount: \(cellBidsArray[section].count) ")
        
        if self.sectionPostsArray.count != 0 && self.cellBidsArray.count != 0 {
            
            numberOfRows = self.cellBidsArray[section].count
            
        } else {
            print("TODO: !!! if the row returns 1 that means there are no BIDS TO DISPLAY")
            numberOfRows = 0
        }
        
        return numberOfRows
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("sellCell", forIndexPath: indexPath) as! SellTableViewCell
        
        
        guard let myFirstPost = sectionPostsArray.first else {
            print("ERROR GETTING first post created")
            print("TODO: !!! if thethere are no BIDS TO DISPLAY & need ot fill in waht shows up here")
            // nTODO FIX
            
            cell.textLabel?.text = "need to fix. no bids to display"
            return cell
        }
        
        // MARK: Selling section: case1. I have no posts to show.
        
        // Because if there is an empty query for post then it will return "placeholder" id
        
        if myFirstPost.id == "placeholder" {
            
            cell.userName.text = "no posts. start listing your item to sell" //message can go here but I put it in the header
            
            // If the 1st post is not placeholder then continue showing data on UI
            
        } else {
            
            
            let bidsForOnePost = cellBidsArray[indexPath.section][indexPath.row]
            
            // MARK: Selling section: case2. I have posts but no bids for my post.
            
            // If the bids is a placeholder, then return message
            
            if bidsForOnePost.bidID == "placeholder" {
                cell.userName.text = "You have no bids for this item"
                
                // UI settings NOTE: HAS plus special additional ones because NO RESPONSE SO HIDE A LOT OF STUFF
                
                cell.acceptOfferButton.hidden = true
                cell.userImage.hidden = true
                cell.offerAmount.hidden = true
                cell.offerPaymentImage.hidden = true
            }
                
                // MARK: Selling section: case3. I have posts and there are bids for my post.
                // Else if bids exist for a particular section then return the BID INFO
                
            else {
                
                
                // set up UI
                
                cell.offerAmount.text = bidsForOnePost.formattedAmount
                
                cell.offerPaymentImage.contentMode = .ScaleAspectFill
                
                if bidsForOnePost.isPaidOnline {
                    cell.offerPaymentImage.image = UIImage(named: "crediticon")
                } else  {
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
                
                
                // Add conditional for when bid is responded to and/or accepted
                
                /// if the bid is open
                
                
                if bidsForOnePost.isRespondedBySeller == false {
                    
                    // attach function for button acceptBid
                    
                    cell.acceptOfferButton.addTarget(self, action: #selector(acceptBid(_:)), forControlEvents: .TouchUpInside)
                    
                    // set up all UI colors & text for this case
                    
                    cell.acceptOfferButton.backgroundColor = UIColor(red: 143.0/255, green: 190.0/255, blue: 0/255, alpha: 1.0)
                    cell.acceptOfferButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    cell.acceptOfferButton.setTitle("Accept Offer", forState: .Normal)
                    cell.acceptOfferButton.enabled = true
                    
                    
                }
                    
                    /// if the bid is closed/responded. everything should still show, except for the button status
                    
                else {
                    
                    // set up all UI colors for this case
                    
                    cell.acceptOfferButton.enabled = false
                    
                    cell.acceptOfferButton.backgroundColor = UIColor.whiteColor()
                    
                    if bidsForOnePost.isAcceptedBySeller {
                        
                        // set up the text for this case
                        
                        cell.acceptOfferButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                        cell.acceptOfferButton.setTitle("accepted", forState: .Normal)
                        
                    } else {
                        
                        // set up the text for this case
                        
                        cell.acceptOfferButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
                        cell.acceptOfferButton.setTitle("not accepted", forState: .Normal)
                    }
                    
                    
                }
                
                
            }
        }
        return cell
    }
    
    // MARK: - Other
    
    deinit {
        print("[DEINIT] SellingTable was killed")
        
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK:  Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
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
