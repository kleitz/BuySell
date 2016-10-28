//
//  AppDelegate.swift
//  esell
//
//  Created by Angela Lin on 9/26/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Use/configure Firebase
        
        FIRApp.configure()
        
//        print("---> [appdel] FIR AUTH VALUE: \(FIRAuth.auth()?.currentUser?.email) // \(FIRAuth.auth()?.currentUser?.uid) ")
//        
//        // Go to main view if alreayd has auth
//        
//        if ((FIRAuth.auth()?.currentUser) != nil) {
//            
//            print("---> [appdel] logged in already, so present main View")
//            
//            // Get a reference to the storyboard
//            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            
//            guard let mainPage = storyboard.instantiateViewControllerWithIdentifier("mainNavig") as? UITabBarController else {
//                
//                print("---> [appdel] ERROR setting up main controller to go to")
//                
//                fatalError()
//            }
//            
//            // Present/set the view controller
//            
//            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            appDelegate.window?.rootViewController = mainPage
//            
//            
//            print("---> [appdel] the root is set as : MAIN navig\n")
//        }
        
        
        Fabric.with([Crashlytics.self])
        
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

