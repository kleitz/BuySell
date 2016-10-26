//
//  NavigationController.swift
//  esell
//
//  Created by Angela Lin on 10/26/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()


        self.navigationBar.translucent = false
   
        self.navigationBar.barStyle = UIBarStyle.Black
        
        self.navigationBar.tintColor = UIColor.orangeColor()
        
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.orangeColor()]
        
    }


}
