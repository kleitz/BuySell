//
//  PostTabBarController.swift
//  esell
//
//  Created by Angela Lin on 10/10/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class PostTabBarController: UITabBarController {
    
    
    // Setup array of posts to be read by table/collection/etc
    
    var posts = [ItemListing]()
    
    
    // Setup image cache. shared by both table & collection views
    
    var imageCache = [String:UIImage]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}
