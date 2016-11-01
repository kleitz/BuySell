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
            // added conditional because previous should never equal the tab that is newItem
            if oldIndex == TabIndex.NewItem.rawValue {
                previousIndex = TabIndex.BrowseList.rawValue
            } else {
                previousIndex = oldIndex
            }
            
            //print("[tab.DidSet] prev: \(TabIndex(rawValue: oldIndex)!)")
        }
        
        willSet(incomingIndex) {
            //print("[tab.WillSet] current: \(TabIndex(rawValue:incomingIndex)!)")
        }
        
    }
    
    var previousIndex: Int = 0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.delegate = self
        
        self.view.backgroundColor = UIColor(red: 242.0/255, green: 239.0/255, blue: 230.0/255, alpha: 1.0)

        // Set UI
        
        // change tint color of tab bar items
        UITabBar.appearance().tintColor = UIColor(red: 21.0/255, green: 44.0/255, blue: 26.0/255, alpha: 1.0)
        
        /// change background/ tint color of tab bar
        UITabBar.appearance().barTintColor = UIColor(red: 252.0/255, green: 250.0/255, blue: 244.0/255, alpha: 1.0)
        
    }

    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {

        print("\n\n [TabBarControl]: you selected another tab: \(self.selectedIndex)")
        
        currentIndex = self.selectedIndex

    }
}

extension UITabBarController {
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? -height : height)
        
        // animate the tabBar
        UIView.animateWithDuration(animated ? 0.2 : 0.0) {
            self.tabBar.frame = CGRectOffset(frame, 0, offsetY)
            self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height + offsetY)
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
    }
}
