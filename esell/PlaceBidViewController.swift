//
//  PlaceBidViewController.swift
//  esell
//
//  Created by Angela Lin on 10/13/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class PlaceBidViewController: UIViewController {

    @IBOutlet weak var viewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let CC = storyboard.instantiateViewControllerWithIdentifier("CreditCardTableViewController") as? CreditCardTableViewController else {
            fatalError("error")
        }
        
        guard let ccview = CC.tableView else {
            fatalError("this is nto working")
        }
        self.viewContainer.addSubview(ccview)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
