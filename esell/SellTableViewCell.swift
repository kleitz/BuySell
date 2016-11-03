//
//  SellTableViewCell.swift
//  esell
//
//  Created by Angela Lin on 10/21/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class SellTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var offerAmount: UILabel!
    
    @IBOutlet weak var offerPaymentImage: UIImageView!
    
    @IBOutlet weak var acceptOfferButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    
        
        // Set up button UI rounded
        
        acceptOfferButton.layer.cornerRadius = 10
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
