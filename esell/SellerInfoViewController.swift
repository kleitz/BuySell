//
//  SellerInfoViewController.swift
//  esell
//
//  Created by Angela Lin on 10/6/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class SellerInfoViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    var sellerInfo = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.presentingViewController)
        
//        
//        guard let vc = self.presentingViewController as? ItemDetailViewController else {
//            fatalError()
//        }
//        
//        
//        
//        print(vc.sellerInfo)
//        
//        if vc.sellerInfo.imageURL != nil {
//            profileImage.image = UIImage(contentsOfFile: vc.sellerInfo.imageURL!)
//        }

        
        closeButton.addTarget(self, action: #selector(closeView), forControlEvents: .TouchUpInside)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeView(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    deinit {
        
        print("(deinit) -> [SELLERViewController]")
    }

}
