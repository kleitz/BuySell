//
//  customBodyCell.swift
//  esell
//
//  Created by Angela Lin on 10/17/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class BodyCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var bidderNameLabel: UILabel!
    
    @IBOutlet weak var bidAmount: UILabel!
    
    @IBOutlet weak var rejectButton: UIButton!
    
    @IBOutlet weak var acceptButton: UIButton!
    

    
    // need to get the bidder image url here [USER]
    // need to get the bidder name here [USER]
    // need to get the offered price here [BID]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
