//
//  PostTabBarController.swift
//  esell
//
//  Created by Angela Lin on 10/10/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class PostTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    enum TabIndex: Int {
        case BrowseList = 0
        case BrowseMap = 1
        case NewItem = 2
        case Message = 3
        case Profile = 4
        
    }
    
    
    // Setup array of posts to be read by table/collection/etc
    
    var posts = [ItemListing]()
    
    
    // Setup image cache. shared by both table & collection views
    
    var imageCache = [String:UIImage]()

    
    // Setup tracking for which tab index is selected

    var currentIndex: Int = 0 {
        
        didSet(oldIndex) {
            previousIndex = oldIndex
            print("[DIDset] old tab#: \(oldIndex)")
        }
        
        willSet(incomingIndex) {
            print("[WILLset] new tab#: \(incomingIndex)")
        }
        
    }
    
    var previousIndex: Int = 0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.delegate = self
        
      
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {

        print("[TabBarControl]: you selected another tab: \(self.selectedIndex)")
        
        currentIndex = self.selectedIndex

    }

}
