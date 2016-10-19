//
//  customBodyCell.swift
//  esell
//
//  Created by Angela Lin on 10/17/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit



class BodyCell: UITableViewCell {
    
    // for selling

    @IBOutlet weak var sellingSectionUserImage: UIImageView!
    @IBOutlet weak var sellingSectionUserName: UILabel!
    @IBOutlet weak var sellingSectionPriceAmount: UILabel!
    @IBOutlet weak var sellingSectionStatusImage: UIImageView!
    
    
    @IBOutlet weak var acceptButton: UIButton!
    
    
    // for buying
    
    @IBOutlet weak var buyingSectionUserImage: UIImageView!
    @IBOutlet weak var buyingSectionUserName: UILabel!
    @IBOutlet weak var buyingSectionPriceAmount: UILabel!
    @IBOutlet weak var buyingSectionStatus: UILabel!
    @IBOutlet weak var buyingSectionStatusImage: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        // Set up button UI rounded
        acceptButton.layer.cornerRadius = 10
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }




}

