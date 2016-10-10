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

        
    }
    
    /// TODO not sure if this is correct. the popup view controller is set here, otherwise it only pops up once if you put it under viewDidLoad (the tab only loads once)
    
    override func viewDidAppear(animated: Bool) {
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        
        let newItemModal = storyboard.instantiateViewControllerWithIdentifier("AddItemViewController")
        
        self.presentViewController(newItemModal, animated: true, completion: nil)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
