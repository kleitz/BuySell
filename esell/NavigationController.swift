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
        
        let backgroundColor = UIColor(red: 109.0/255, green: 88.0/255, blue: 67.0/255, alpha: 1.0)
        
        self.view.backgroundColor = backgroundColor
        
        self.navigationBar.barTintColor = backgroundColor
        
        self.navigationBar.tintColor = UIColor.whiteColor()
        
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
    }


}
