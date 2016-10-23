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
    
    @IBOutlet weak var titleText: UITextField!
   
    @IBOutlet weak var priceText: UITextField!
    
    @IBOutlet weak var descriptionText: UITextView!
    
    @IBOutlet weak var pickupText: UITextField!
 
    @IBOutlet weak var acceptOnlinePaymentSwitch: UISwitch!
    
    @IBOutlet weak var acceptShippingOptionSwitch: UISwitch!
    
    @IBOutlet weak var pickupSwitch: UISegmentedControl!
    
    
    var imagePicker = UIImagePickerController()
    
    var pickupLocationPicker = UIPickerView()
    
    var pickupLocationValues: [String] = ["MRT Taipei Main", "MRT Shuanglian", "MRT Zhongshan", "MRT Minquan E Rd", "MRT Dongmen"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up navigation items such as title
        
        self.navigationItem.title = "Create Post"
        
        let cancelButton =  UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(closeModal))
        let postButton = UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(clickSavePost))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = postButton
        
        
        // Setup segment control for pickup option
        setupPickupSegmentControl()
        
        // Hide the picker's uipickerview
        
        pickupLocationPicker.dataSource = self
        pickupLocationPicker.delegate = self
        
        pickupText.inputView = pickupLocationPicker
 
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
        
        
        // Code to handle pickup location text field tap gesture
        
        let tapOnPickup = UITapGestureRecognizer(target: self, action: #selector(selectPickupLocation))
        
        pickupText.addGestureRecognizer(tapOnPickup)
        
        
    }
    
   
    
    // Function attached to pickupTextField
    func selectPickupLocation(gesture: UIGestureRecognizer) {
        
        pickupLocationPicker.hidden = false
    }
    
    // Function to setup pickup Segment Control option
    func setupPickupSegmentControl() {
        
        pickupSwitch.addTarget(self, action: #selector(clickPickupSwitch), forControlEvents: UIControlEvents.ValueChanged)
        
         // Set default segment that is Selected upon load
        pickupSwitch.selectedSegmentIndex = 0
    }
    
    func clickPickupSwitch() {
        switch pickupSwitch.selectedSegmentIndex {
        case 0:
            print("select MRT")
            // bring up choose mrt list
            pickupText.becomeFirstResponder()
            
        case 1:
            print("select choose from Map")
            pickupText.text = nil
            // bring up map view
            
           
        default: break;
        }
    }
    
    // Function attached to UIImageview for selecting photo from photolibrary
    func selectImage(gesture: UIGestureRecognizer) {
        
        /// The special action sheet for user to choose between camera / photogallery
        
        //show the action sheet (i.e. the little pop-up box from the bottom that allows you to choose whether you want to pick a photo from the photo library or from your camera)
        
        let optionMenu = UIAlertController(title: nil, message: "Where would you like the image from?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let photoLibraryOption = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
            
            print(" > clicked to selectImage FROM LIBRARY")
            
            //shows the image picker
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.imagePicker.allowsEditing = true
                self.imagePicker.modalPresentationStyle = .Popover
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }

        })
        
        let cameraOption = UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
            
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

        })
        
        //Adding the actions to the action sheet. Here, camera will only show up as an option if the camera is available in the first place.
        optionMenu.addAction(photoLibraryOption)
        optionMenu.addAction(cancelOption)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == true {
            optionMenu.addAction(cameraOption)} else {
            print("I don't have a camera.")
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
        
        // use [UIImagePickerControllerEditedImage] intsead of [...OriginalImage] if allow editing = true
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        imageView.contentMode = .ScaleAspectFit
        imageView.image = chosenImage
        
        dismissViewControllerAnimated(true, completion: nil)
        
        // hide the photo placeholders once the image is picked
        photoIcon.hidden = true
        
    }
    
    func clickSavePost() {
        
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
        
        
        /// TODO need to add a better check for this NUMBER input
        
        guard let itemPriceString = priceText.text where itemPriceString != "" else {
            popupNotifyIncomplete()
            return
        }
        
        /// TODO FIX this 0 error handling later
        let itemPrice = Double(itemPriceString) ?? 0
        
        // note: don't need to guard for selectors for credit card and shipping
        
        
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
            
            
            // Actual save happens here, after the checking
            // use separate function to save all info into firebase database (including the url string of the image)
            
            // Pass to Firebase
            
            let fireBase = FirebaseManager()
            
            fireBase.saveNewPostInDataBase(imageURL: imageURL, itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: itemPrice, onlinePaymentOption: self.acceptOnlinePaymentSwitch.on, shippingOption: self.acceptShippingOptionSwitch.on)
            
        }
        
        // Notify user when post is successfully posted/saved
        
        popupNotifyPosted()
        
        
        // Reset all the fields after save is done
        // DELETE THIS IF DISMISSING AFTER SAVED?
        
        
        
    }
    
    
    
    
    // Popup alert if missing fields
    
    func popupNotifyIncomplete(){

        let alertController = UIAlertController(title: "Wait!", message:
            "You need to fill out all fields", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { action in
            print("test: pressed Dismiss")
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
    // Popup alert if Post Successful
    //completion completion: ()?
    func popupNotifyPosted(){

        let alertController = UIAlertController(title: "Post Completed", message:
            "Your item has been posted!", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { action in self.closeModal() } ))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // UIPickerView functions for selecting location from a picker
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
    
    // Dismiss Keyboard functions
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // I dont think this one works (supposed to dismiss keyboard upeon hitting enter - only for UITextField)
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Reset all fields function 
    
    func resetAllFields() {
        
        photoIcon.hidden = false
        imageView.image = nil
        titleText.text = ""
        descriptionText.text = ""
        priceText.text = ""
        
        pickupText.text = nil
        pickupSwitch.selectedSegmentIndex = 0
        acceptOnlinePaymentSwitch.on = false
        acceptShippingOptionSwitch.on = false
    }
    
    
    // Close this view controller
    
    func closeModal() {
        if let parent = self.presentingViewController as? PostTabBarController {
            parent.selectedIndex = parent.previousIndex
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    deinit {
        print("(deinit) -> [AddItemViewController]")
    }
}


