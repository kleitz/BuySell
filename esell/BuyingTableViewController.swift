//
//  BuyingTableViewController.swift
//  esell
//
//  Created by Angela Lin on 10/20/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit


class BuyingTableViewController: UITableViewController {
    
    
    // MARK: Data Variables
    
    // for section/header
    var sectionPostsArray = [ItemListing]()  // { didSet { tableView.reloadData() } }
    
    // for each section/header cell
    var cellBidsArray = [BidForItem]()  // { didSet { tableView.reloadData() } }
    
    
    let fireBase = FirebaseManager()
    
    
    // MARK:- Lifecycle ViewWillAPPEAR
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        sectionPostsArray = [ItemListing]()
        
        let currentUser = getUserID()
        
        fireBase.fetchBidsByUserID(userID: currentUser) { (bidsCreated) in
            print("returning bidsCreated \(bidsCreated)")
            
            
            // SAVE CELL DATA
            self.cellBidsArray = bidsCreated
            
            
            for bid in self.cellBidsArray {
                
                // for each bid, look up the parent post so we can display post info in the table
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    self.fireBase.lookupSinglePost(postID: bid.parentPostID, withCompletionHandler: { (post) in
                        
                        print(" __[1.upper][fetchSinglePost]  -> 1 post returned from handler: \(post.title)")
                        
                        // SAVE SECTION DATA
                        self.sectionPostsArray.append(post)
                        
                        /// 1c Fetch user info out of each POST Set - requires another QUERY
                        // Then add returned info to local dictionary
                        
                        self.fireBase.lookupSingleUser(userID: post.author, withCompletionHandler: { (getUser) in
                            
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
        
    }
    
    // MARK: Lifecycle ViewDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(" >> BuyingTable loaded ")
        
        self.tableView.rowHeight = 70.0
        
    }
    
    // MARK: Lifecycle ViewWillDISAPPEAR
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print(" >> buyingTable is disappearing... removing observers ")
        fireBase.ref.removeAllObservers()
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
        
        let postIBidOn = sectionPostsArray[section]
        
        headerView.titleLabel.text = postIBidOn.title
        headerView.priceLabel.text = postIBidOn.formattedPrice
        
        
        return headerView
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return sectionPostsArray.count
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("buyCell", forIndexPath: indexPath) as! BuyTableViewCell
        
        // use indexPath.section instead of indexPath.row for the bid because it's 1:1 relationship
        // MARK: Buying section: must exist. show my 1 bid under parent post
        
        ///NEED ERROR HANDLING HERE IN CASE ARRAY IS EMPTY UPON LOAD
        
        print("WHY DOES INDEXpath fail: \(indexPath.section)")
        print("count of array: \(sectionPostsArray.count)")
        
        let myOfferForPost = cellBidsArray[indexPath.section]
        
        //cell.buyingSectionPriceAmount.text = ""
        //("Made an offer of \(postIBidOn.formattedAmount).")actually don't need this in the above label.. assume same price
        
        
        // Add conditional for when bid is responded to and/or accepted
        
        /// if the bid is open
        
        
        if cellBidsArray[indexPath.section].isRespondedBySeller {
            
            if cellBidsArray[indexPath.section].isAcceptedBySeller {
                
                // print("~~ MY BID WAS ACCEPTED")
                cell.offerStatus.text = "has ACCEPTED YOUR OFFER!"
                cell.offerStatus.textColor = UIColor.darkTextColor()
                
            } else {
                
                // print("~~ MY BID WAS REJECTED")
                cell.offerStatus.text = "has DECLINED your offer"
                cell.offerStatus.textColor = UIColor.darkGrayColor()
                
            }
            
            
            
        } else {
            
            /// if the bid is closed/responded. everything should still show, except for the button status
            
            
            // cell.textLabel?.text = "no repsonse"
            cell.offerStatus.text = "has not responded yet"
            cell.offerStatus.textColor = UIColor.lightGrayColor()
            
        }
        
        // Set seller profile iamage
        
        // print("~~~ BUYSECTION getting userID from async local var: #\(indexPath.row):: \(postsBuying[indexPath.row].author) print\(postIBidOn.parentPostUserInfo?.imageURL)\n ")
        
        if let userCompleteFromBid: User = myOfferForPost.parentPostUserInfo {
            
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
            }
        }
        
        
        return cell
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
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Other
    
    // for image rounding for the button in tableView for accepting bid
    
    private func roundUIView(view: UIView, cornerRadiusParams: CGFloat!) {
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadiusParams
    }
    
    // Get user ID function
    
    func getUserID() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard let userID = defaults.stringForKey("uid") else {
            fatalError("failed getting nsuserdefaults uid")
        }
        
        return userID
    }
    
    
    deinit {
        
        print("[DEINIT] BuyingTable was killed")
        
    }
}
