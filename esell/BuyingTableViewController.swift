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
    
    var delegate: BuyingStillLoadingDelegate?
    
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
                    // is this the correct place to put stop loading?
                    self.delegate?.stopLoading(self, isFinishedLoading: true)
                }
            }
            
            
            
        }
        
    }
    
    // MARK: Lifecycle ViewDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(" >> BuyingTable loaded ")
        
        self.tableView.rowHeight = 70.0
        
        // Remove table view seperator lines
        tableView.separatorStyle = .None
        
    }
    
    // MARK: Lifecycle ViewWillDISAPPEAR
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print(" >> buyingTable is disappearing... removing observers ")
        fireBase.ref.removeAllObservers()
    }
    
    
    
    // MARK: - Table view HEADER/SECTION
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        print("sectoin count \(sectionPostsArray.count)")
        
        if sectionPostsArray.count == 0 {
            
            return 1
            
        }
        
        return sectionPostsArray.count
    }

    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Create UIView from the custom nib
        
        let headerView = UINib(nibName: "SectionHeaderView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! SectionHeaderView
        
        // Use autolayout resizing
        
        headerView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        headerView.titleLabel.text = ""
        headerView.priceLabel.text = ""
        
        
        for index in 0...section {
            if let postIBidOn = sectionPostsArray[safe: index] {
                headerView.titleLabel.text = postIBidOn.title
                headerView.priceLabel.text = postIBidOn.formattedPrice
            }
        }

        return headerView
    }
    
    //MARK: Table view: NumberOFROWS/CELLS
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("buyCell", forIndexPath: indexPath) as! BuyTableViewCell
        
        // set UI as hidden for cell, if sectionCountt=0
        setDefaultCellUI(cell, isHidden: true)
        
        
        if sectionPostsArray.count > 0 {
            
            // set UI as SHown for cell, if there are sections.
            setDefaultCellUI(cell, isHidden: false)
            
            // use indexPath.section instead of indexPath.row for the bid because it's 1:1 relationship
            // MARK: Buying section: must exist. show my 1 bid under parent post
            
            let myOfferForPost = cellBidsArray[indexPath.section]
            
            //cell.buyingSectionPriceAmount.text = ""
            //("Made an offer of \(postIBidOn.formattedAmount).")actually don't need this in the above label.. assume same price
            
            
            
            // if the bid is responded by seller
            
            switch cellBidsArray[indexPath.section].isRespondedBySeller {
                
            case true:
                
                // if respondeded, then check whether Accepted
                
                switch cellBidsArray[indexPath.section].isAcceptedBySeller {
                    
                case true:
                    // print("~~ MY BID WAS ACCEPTED")
                    cell.offerSentAmount.text = "You sent an offer of \(myOfferForPost.formattedAmount)"
                    cell.offerStatus.text = "has ACCEPTED YOUR OFFER!"
                    cell.offerStatus.textColor = UIColor.darkTextColor()
                case false:
                    // print("~~ MY BID WAS REJECTED")
                    cell.offerSentAmount.text = "You sent an offer of \(myOfferForPost.formattedAmount)"
                    cell.offerStatus.text = "has DECLINED your offer"
                    cell.offerStatus.textColor = UIColor.darkGrayColor()
                }
                
            case false:
                
                // if the bid is not responded. everything should still show, except for the button status
                cell.offerSentAmount.text = "You sent an offer of \(myOfferForPost.formattedAmount)"
                cell.offerStatus.text = "has not yet responded"
                cell.offerStatus.textColor = UIColor.lightGrayColor()
                
            }
            
            
            // Get seller profile iamage to show
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
            
        }
        return cell
    }
    

    
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
    

    private func setDefaultCellUI(cell: BuyTableViewCell, isHidden: Bool) {
        
        cell.offerSentAmount.hidden = isHidden  
        cell.userImage.hidden = isHidden
        cell.userName.hidden = isHidden
        cell.offerStatus.hidden = isHidden
        
    }
    
    deinit {
        
        print("[DEINIT] BuyingTable was killed")
        
    }
}

extension CollectionType {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
