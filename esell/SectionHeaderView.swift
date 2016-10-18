//
//  MyCustomView.swift
//  esell
//
//  Created by Angela Lin on 10/18/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class SectionHeaderView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var view: UIView!
 
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
 
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        
//        super.init(coder: aDecoder)
//        setup()
//    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "SectionHeaderView", bundle: bundle)
        view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    
}
