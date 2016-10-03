//
//  SegmentViewController.swift
//  
//
//  Created by Angela Lin on 10/3/16.
//
//

import UIKit

enum Segment: Int {
    case table = 0
    case collection = 1
}

class SegmentViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up segment control images and attach function
        
        setupSegmentControl()
        
        
        // Set up title
        
        self.navigationItem.title = "Browse Items"
        
        
    }
    
    func setupSegmentControl() {
        
        // the default segment selected is 0 (Table view)
        
        segmentControl.selectedSegmentIndex = Segment.table.rawValue
        
        
       
        segmentControl.addTarget(self, action: #selector(segmentChanged), forControlEvents: UIControlEvents.ValueChanged)
        
        //segmentControl.removeBorders()
        
        
    }
    
    func segmentChanged() {
        switch segmentControl.selectedSegmentIndex
        {
        case 0: print("blah 1")
        case 1: print("blah 2")
        default: break;
        }
    }
    


}

//extension UISegmentedControl {
//    
//    func removeBorders() {
//        
//        
//        setBackgroundImage(imageWithColor(UIColor.clearColor()), forState: .Normal, barMetrics: .Default)
//        setBackgroundImage(imageWithColor(tintColor!), forState: .Selected, barMetrics: .Default)
//        setDividerImage(imageWithColor(UIColor.clearColor()), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
//    }
//    
//    
//    // create a 1x1 image with this color
//    
//    private func imageWithColor(color: UIColor) -> UIImage {
//        
//        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
//        UIGraphicsBeginImageContext(rect.size)
//        let context = UIGraphicsGetCurrentContext()
//        CGContextSetFillColorWithColor(context, color.CGColor);
//        CGContextFillRect(context, rect);
//        let image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        return image
//    }
//    
//}
