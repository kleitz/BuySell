//
//  AddItemBackgroundViewController.swift
//  esell
//
//  Created by Angela Lin on 10/10/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class AddItemBackgroundViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 252.0/255, green: 250.0/255, blue: 244.0/255, alpha: 1.0)
        
    }
    
    
    // MARK: - Navigation. Pop up separate view controller
    
    
    /// TODO not sure if this is correct. the popup view controller is set here, otherwise it doesnt work.. but it's slow when you load it the FIRST TIME>
    // can't use viewDidLoad - only pops up once if you put it under viewDidLoad (the tab only loads once).
    // can't use viewWillAppear - makes it continuously pop up once you cloes it
    
    override func viewDidAppear(animated: Bool) {
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        
        let newItemModal = storyboard.instantiateViewControllerWithIdentifier("AddItemView") as! UINavigationController
        
        
        self.presentViewController(newItemModal, animated: true, completion: nil)
        
    }
    
  
}
