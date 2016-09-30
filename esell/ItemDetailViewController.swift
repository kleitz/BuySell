//
//  ItemDetailViewController.swift
//  esell
//
//  Created by Angela Lin on 9/30/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {
    
   
    @IBOutlet weak var itemTitle: UILabel!
    
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var itemDescription: UILabel!
    
    @IBOutlet weak var itemPrice: UILabel!
    
    @IBOutlet weak var itemSeller: UILabel!
    
    
    
    var post = ItemListing()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("title test print: \(post.title)")
        
        // set up the UI elements with ItemListing attributes passed in

        // OPTIONALS UNWRAP> make sure none of the post attributes are OPtional
        
        if let title = post.title {
            itemTitle.text = title
        }
        
        if let price = post.price {
            itemPrice.text = price
        }
        
        if let description = post.itemDescription {
            itemDescription.text = description
        }

        if let unwrappedImageURL: String = post.imageURL,
        let url = NSURL(string: unwrappedImageURL),
        let imageData = NSData(contentsOfURL: url) {
            itemImage.image = UIImage(data: imageData)
        }
        
        // oh no the author is the UID which isn't for the UI to show....
        if let seller = post.author,
        let date = post.createdDate {
            itemSeller.text = ("Posted by \(seller) on \(date) ")
        }
        
        
    
        // TODO need to write a query here to get the SELLER INFO to appear, including the actual name of the author UID
        
        
        
        
        
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
    deinit {
        print("(deinit) -> [ItemDetailViewController]")
    }
}
