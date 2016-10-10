//
//  AddItemViewController.swift
//  esell
//
//  Created by Angela Lin on 9/27/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import Firebase


class AddItemViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet var imageView: UIImageView!
    
    
    @IBOutlet weak var photoIcon: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var titleText: UITextField!
   
    @IBOutlet weak var priceText: UITextField!
    
    @IBOutlet weak var descriptionText: UITextView!
    
    
    @IBOutlet weak var pickupText: UITextField!
    
    
    @IBOutlet weak var closeButton: UIButton!
    
    
    var imagePicker = UIImagePickerController()
    
    var pickupLocationPicker = UIPickerView()
    
    var pickupLocationValues: [String] = ["Choose pickup location", "MRT Taipei Main", "MRT Shuanglian", "MRT Zhongshan", "MRT Minquan E Rd", "MRT Dongmen"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up title
        
        self.navigationItem.title = "Post an Item to Sell"
        
    
        // Hide the picker
        
        pickupLocationPicker.dataSource = self
        pickupLocationPicker.delegate = self
        
        pickupText.inputView = pickupLocationPicker
        pickupText.placeholder = pickupLocationValues[0]
        
        
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self

        // Looks for single or multiple taps. FOr dismissing keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Create tap gesture recognizer
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        
        // Add it to image view & Make sure image view is interactable
        
        imageView.addGestureRecognizer(tapGesture)
        imageView.userInteractionEnabled = true
        
        
        // UI Stuff : make photo icon white color, not original black color
        photoIcon.image = photoIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        photoIcon.tintColor = UIColor.whiteColor()
        
        photoIcon.hidden = false
        
        // Add save button fucntion
        
        saveButton.addTarget(self, action: #selector(savePostButton), forControlEvents: .TouchUpInside)
        
        
        // Code to handle pickup location text field tap gesture
        let tapOnPickup = UITapGestureRecognizer(target: self, action: #selector(selectPickupLocation))
        
        pickupText.addGestureRecognizer(tapOnPickup)
       

        // Code to close the new item viewcontroller
        closeButton.addTarget(self, action: #selector(closeModal), forControlEvents: .TouchUpInside)
        
    }
    
   
    
    // Function attached to pickupText
    func selectPickupLocation(gesture: UIGestureRecognizer) {
        
        pickupLocationPicker.hidden = false
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
        imageView.contentMode = .ScaleAspectFit
        imageView.image = chosenImage
        dismissViewControllerAnimated(true, completion: nil)
        
//        // hide the photo placeholders once the image is picked
        photoIcon.hidden = true
//        photoLabel.hidden = true
        
    }
    
    func savePostButton() {
        
        // Create STORAGE ref for images only (not database reference)
        
        let imageName = NSUUID().UUIDString
    
        let storageRef = FIRStorage.storage().reference().child("post_images").child("\(imageName).png")
        
        
        
        // Do error checking for all fields to make sure before saving
        
        guard let imageFromPicker = self.imageView.image else {
            popupNotifyIncomplete()
            print("error w/ unwrapping image or image is empty")
            return
        }
        
        guard let imageData = UIImagePNGRepresentation(imageFromPicker) else {
            print("error w/ converting image to NSData")
            return
        }
        
        guard let itemTitle = titleText.text where itemTitle != "" else {
            popupNotifyIncomplete()
            return
        }
        
        guard let itemDescription = descriptionText.text where itemDescription != "" else {
            popupNotifyIncomplete()
            return
        }
        
        guard let itemPrice = priceText.text where itemPrice != "" else {
            popupNotifyIncomplete()
            return
        }
        
        // After checking is ok, store in storage (the image gets its own url)
        
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
            
            self.saveNewPostInDataBase(imageURL: imageURL, itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: itemPrice)
            
        }
        
        /// if the root view controller is the login page....this dismissing doesnt' work becuase it closes teh whole thing
        /// if the root veiw controllers is the posts page... it doesn't even dsmiss (can't dismiss itslef, it'sattached to the posts page)
        
        // self.dismissViewControllerAnimated(true, completion: nil)
     
        
//       // ok instead of moving, just do a pop up saying it's posted. 
        // Move view after the save is done
//        self.tabBarController?.selectedIndex = 0
        
        popupNotifyPosted()
        
        // Reset all the fields after save is done
        photoIcon.hidden = false
        imageView.image = nil
        titleText.text = ""
        descriptionText.text = ""
        priceText.text = ""
        
    }
    
    func saveNewPostInDataBase(imageURL imageURL: String, itemTitle: String, itemDescription: String, itemPrice: String){
        // do saving into firebase here
        // TODO fix this so that it doesn't save the image first into database before checking all fields?
        
        let ref = FIRDatabase.database().referenceFromURL("https://esell-bf562.firebaseio.com/")
        
        let postsRef = ref.child("posts")
        
        let newPostRef = postsRef.childByAutoId()
        
        
        // Get the userID from userdefaults to save as "author" key
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard let uid = defaults.stringForKey("uid") else {
            print("failed getting nsuserdefaults uid")
            return
        }
        
        
        // Set the dictionary of values to be saved in database for "POSTS"
        
        let values = [ "title": itemTitle, "price": itemPrice, "description": itemDescription, "author": uid, "created_at": FIRServerValue.timestamp(), "image_url": imageURL ]
        
        newPostRef.updateChildValues(values as [NSObject : AnyObject], withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err?.localizedDescription)
                return
            }
            
            print("saved POSTinfo successfly in firebase DB")
            

        })
    }
    
    
    func popupNotifyIncomplete(){
        
        // add popup alert if missing fields
        
        let alertController = UIAlertController(title: "Wait!", message:
            "You need to fill out all fields", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func popupNotifyPosted(){
        
        // add popup alert if missing fields
        
        let alertController = UIAlertController(title: "Post Completed", message:
            "Your item has been posted!", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView)->Int {
        
        return 1
    }
    
    func pickerView(pickerView: UIPickerView,numberOfRowsInComponent component:Int) -> Int{
        
        return pickupLocationValues.count
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)->String?{
        
        return pickupLocationValues[row]
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        print("SELECTED FROM PICKER --> \(pickupText.text)")

        pickupText.text = pickupLocationValues[row]
        
        self.view.endEditing(true)
    
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func closeModal() {
        
        if let parent = self.presentingViewController as? UITabBarController {
            
            parent.selectedIndex = 0
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
//    
//    func textFieldDidBeginEditing(textField: UITextField) {
//        
//        pickupLocationPicker.hidden = false
//    }
    
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
//        
//        pickupLocationPicker.hidden = false
//        return false
//        
//    }
    
    
    deinit {
        print("(deinit) -> [AddItemViewController]")
    }
}


