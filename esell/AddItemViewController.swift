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
        
        // Set up title
        
        self.navigationItem.title = "Post an Item to Sell"
        

        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self

        
        
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
        
        /// The special action sheet for user to choose between camera / photogallery
        
        //show the action sheet (i.e. the little pop-up box from the bottom that allows you to choose whether you want to pick a photo from the photo library or from your camera)
        
        let optionMenu = UIAlertController(title: nil, message: "Where would you like the image from?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let photoLibraryOption = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
            
            print(" > clicked to selectImage FROM LIBRARY")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.imagePicker.allowsEditing = true
                self.imagePicker.modalPresentationStyle = .Popover
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }

        })
        
        let cameraOption = UIAlertAction(title: "Take a photo", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
            print(" > clicked to selectImage FROM take a photo")
            //shows the camera
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .Camera
            self.imagePicker.modalPresentationStyle = .Popover
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
        })
        
        let cancelOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancel")
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        //Adding the actions to the action sheet. Here, camera will only show up as an option if the camera is available in the first place.
        optionMenu.addAction(photoLibraryOption)
        optionMenu.addAction(cancelOption)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == true {
            optionMenu.addAction(cameraOption)} else {
            print ("I don't have a camera.")
        }
        
        //Now that the action sheet is set up, we present it.
        self.presentViewController(optionMenu, animated: true, completion: nil)
        

    }
    
    // ImagePicker Delegate Methods
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        print("   > canceled selectImage")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print(" > finished picking image w/ edit")
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
        
        let imageName = NSUUID().UUIDString
    
        let storageRef = FIRStorage.storage().reference().child("post_images").child("\(imageName).png")
        
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
        
        /// if the root view controller is the login page....this dismissing doesnt' work becuase it closes teh whole thing
        /// if the root veiw controllers is the posts page... it doesn't even dsmiss (can't dismiss itslef, it'sattached to the posts page)
        // self.dismissViewControllerAnimated(true, completion: nil)
        
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
        print("(deinit) -> [AddItemViewController]")
    }
}

