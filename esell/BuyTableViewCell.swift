//
//  BuyTableViewCell.swift
//  esell
//
//  Created by Angela Lin on 10/21/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class BuyTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var offerStatus: UILabel!
    
    // TODO later add status Image
    // TODO later add price if allow differnet bid amounts
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
