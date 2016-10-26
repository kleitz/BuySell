//
//  ListingsCollectionViewController.swift
//  esell
//
//  Created by Angela Lin on 10/3/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit



class ListingsCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let reuseIdentifier = "cell"
    
    var sourceViewController = PostTabBarController()
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    
    
    @IBOutlet var collectionView: UICollectionView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("_collectionView view loaded")

        sourceViewController = self.parentViewController?.tabBarController as! PostTabBarController
        
    }
    
//    override func viewWillAppear(animated: Bool) {
//        
//        super.viewWillAppear(true)
//        
//        // SET TAB BAR USING THIS FUNCTION w/Animation so that there is no white space when segue
//        setTabBarVisible(!tabBarIsVisible(), animated: false)
//        
//    }
//
//    override func viewWillDisappear(animated: Bool) {
//        
//        super.viewWillDisappear(true)
//        
//        // SET TAB BAR USING THIS FUNCTION w/Animation so that there is no white space when segue
//        setTabBarVisible(false, animated: true)
//        
//    }
    

    
    // MARK: UICollectionView Delegate
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let numberOfItemsPerRow = 2
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 5
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        
        return CGSize(width: size, height: size)
    }
    
    // MARK: UICollectionView DataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sourceViewController.posts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let post = sourceViewController.posts[indexPath.row]
        
        // Configure the cell
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        
        
        cell.labelText.text = post.formattedPrice
        
        cell.imageView.backgroundColor = UIColor.whiteColor()
        //cell.imageView.image = post.imageAsUIImage
        cell.imageView.contentMode = .ScaleAspectFill
        
        // Image handling
        
        // temp set image
        cell.imageView.image = UIImage(named:"shopbag")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            // Jump in to a background thread to get the image for this item
            
            // Check our image cache for the existing key. This is just a dictionary of UIImages
            
            guard let imageURL = post.imageURL else {
                fatalError()
            }
            
            
            let image: UIImage? = self.sourceViewController.imageCache[imageURL]
            
            if (image == nil) {
                
                // If the image does not exist, we need to download it
                guard let imgURL = NSURL(string: imageURL) else {
                    fatalError("error unwrap string to NSURL")
                }
                
                // Download an NSData representation of the image at the URL
                let urlRequest = NSURLRequest(URL: imgURL)
                
                print("--> start request grab imageData from URLstring")
                
                let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
                    if error == nil {
                        
                        guard let unwrappedData = data else {
                            fatalError()
                        }
                        
                        guard let image = UIImage(data: unwrappedData) else {
                            fatalError()
                        }
                        
                        // Store the image in to our cache
                        
                        self.sourceViewController.imageCache[imageURL] = image
                        
                        
                        // Display image (using main thread)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.imageView.image = image
                            cell.imageView.contentMode = .ScaleAspectFill
                        })
                        
                    } else {
                        
                        print(error?.localizedDescription)
                    }
                })
                
                task.resume()
                
            } else {
                print("--> start show image, already in imageCache")
                // Display image (using main thread)
                
                dispatch_async(dispatch_get_main_queue(), {
                    cell.imageView.image = image
                    cell.imageView.contentMode = .ScaleAspectFill
                })
            }
        }

        return cell

    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        print(" >> collectionView. selected @ #\(indexPath.row)")
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print(" >> started segue")
        
        if let identifier = segue.identifier {
            
            switch identifier {
                
            case "segueCollectionToItemDetail":
                
                if let cell = sender as? UICollectionViewCell {
                    
                    let rowIndex = self.collectionView.indexPathForCell(cell)!.row
                    
                    guard let itemDetailController = segue.destinationViewController as? ItemDetailViewController else {
                        fatalError("seg failed")
                    }
                    
                    itemDetailController.post = sourceViewController.posts[rowIndex]
                    
                    
                    // for passing image
                    if let image: UIImage = sourceViewController.imageCache[sourceViewController.posts[rowIndex].imageURL!] {
                        itemDetailController.image = image
                    }

                    itemDetailController.tabBarController?.tabBar.hidden = true
                    

                }
            default: break
            }
        }
        
    }


}

