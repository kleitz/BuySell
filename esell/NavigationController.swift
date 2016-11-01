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
        
        let mainBlueColor = UIColor(red: 20.0/255, green: 164.0/255, blue: 226.0/255, alpha: 1.0)
        
        self.navigationBar.barTintColor = mainBlueColor
        
        self.navigationBar.tintColor = UIColor.whiteColor()
        
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
    }


}
