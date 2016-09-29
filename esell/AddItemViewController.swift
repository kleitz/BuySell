//
//  AddItemViewController.swift
//  esell
//
//  Created by Angela Lin on 9/27/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import Firebase


class AddItemViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var titleText: UITextField!
   
    @IBOutlet weak var priceText: UITextField!
    
    @IBOutlet weak var descriptionText: UITextView!
    
    
    var imagePicker = UIImagePickerController()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       
        
        
        
        // Create tap gesture recognizer
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        
        // Add it to image view & Make sure image view is interactable
        
        imageView.addGestureRecognizer(tapGesture)
        imageView.userInteractionEnabled = true
        
        
        // Add save button fucntion
        
        saveButton.addTarget(self, action: #selector(savePostButton), forControlEvents: .TouchUpInside)
        
    }

    
    // Function attached to UIImageview for selecting photo from photolibrary
    func selectImage(gesture: UIGestureRecognizer) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            
            print(" > clicked to selectImage")
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // ImagePicker Delegate Methods (2 of them)
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        print("   > canceled selectImage")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        print("   > completed selectImage")
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = .ScaleAspectFill
        imageView.image = chosenImage
        dismissViewControllerAnimated(true, completion: nil)
        
//        // hide the photo placeholders once the image is picked
//        photoIcon.hidden = true
//        photoLabel.hidden = true
        
    }
    
    func savePostButton() {
        
        // Create STORAGE ref for images only (not database reference)
        
        let storageRef = FIRStorage.storage().reference().child("image.png")
        
        guard let imageFromPicker = self.imageView.image else {
            print("error w/ unwrapping image")
            return
        }
        
        guard let imageData = UIImagePNGRepresentation(imageFromPicker) else {
            print("error w/ converting image to NSData")
            return
        }
        
        // Store in storage (the image gets its own url)
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            print(metadata)
            
            guard let imageURL = metadata?.downloadURL()?.absoluteString else {
                print("unable to get imageURL")
                return
            }
            
            // use separate function to save all info into firebase database (including the url string of the image)
            
            self.saveNewPostInDataBase(imageURL: imageURL)
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func saveNewPostInDataBase(imageURL imageURL: String){
        // do saving into firebase here
        
        let ref = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com/")
        
        let postsRef = ref.child("posts")
        
        let newPostRef = postsRef.childByAutoId()
        
        guard let itemTitle = titleText.text,
            itemDescription = descriptionText.text,
            itemPrice = priceText.text else {
                print("error")
                return
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard let uid = defaults.stringForKey("uid") else {
            print("failed getting nsuserdefaults uid")
            return
        }
        
        let values = [ "title": itemTitle, "price": itemPrice, "description": itemDescription, "author": uid, "created_at": FIRServerValue.timestamp(), "image_url": imageURL ]
        
        newPostRef.updateChildValues(values as [NSObject : AnyObject], withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err?.localizedDescription)
                return
            }
            
            print("saved POSTinfo successfly in firebase DB")
            
//            postsRef.child("created_at").observeEventType(.Value, withBlock: { (snap) in
//                if let t = snap.value as? NSTimeInterval {
//                    print(NSDate(timeIntervalSince1970: t/1000))
//                }
//            })
        })
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
        print("(deinit) -> AddNew view")
    }
}

