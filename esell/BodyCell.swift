//
//  customBodyCell.swift
//  esell
//
//  Created by Angela Lin on 10/17/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

protocol BodyCellDelegate: class {
    
    func presentView(manager: BodyCell, wasClicked: Bool)
    
}

class BodyCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var bidderNameLabel: UILabel!
    
    @IBOutlet weak var bidAmount: UILabel!
    
 
    @IBOutlet weak var acceptButton: UIButton!
    

    weak var delegate: BodyCellDelegate?
    
    // need to get the bidder image url here [USER]
    // need to get the bidder name here [USER]
    // need to get the offered price here [BID]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        // set up button functions
        
        acceptButton.addTarget(self, action: #selector(acceptBid), forControlEvents: .TouchUpInside)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    // OTHER FUNCS
    
    func acceptBid() {
        
        print("clicked accept")
        
        self.delegate?.presentView(self, wasClicked: true)
        // error Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (<UIAlertController: 0x7fbf85b2add0>)
       
        //popupNotifyPosted(title: "Asdf", message: "asdf")
    }
    
    
    func rejectBid() {
        
        print("clicked reject")
        
        //popupNotifyPosted(title: "Asdf", message: "asdf")
    }
    
    
    


}
