//
//  AddItemTableViewController.swift
//  esell
//
//  Created by Angela Lin on 10/24/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import Firebase

class AddItemTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    // MARK: IBOutlet Variables
    
    @IBOutlet weak var photoIcon: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleText: UITextField!
    
    @IBOutlet weak var priceText: UITextField!

    @IBOutlet weak var descriptionText: UITextView!
    
    @IBOutlet weak var acceptOnlinePaymentSwitch: UISwitch!
    
    @IBOutlet weak var willingToShipSwitch: UISwitch!
    
    @IBOutlet weak var selectPickupText: UILabel!
    
    @IBOutlet weak var pickupStaticCell: UITableViewCell!
    
    @IBOutlet weak var selectPickupButton: UIButton!
    
    
    // MARK: Data Variables
    
    var imagePicker = UIImagePickerController()
    
    
    // MARK:- ViewDidLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set up navigation items such as title
        
        self.navigationItem.title = "Create Post"
        
        let cancelButton =  UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(closeModal))
        let postButton = UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(clickSavePost))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = postButton
        
        
        // Set image picker delegate
        
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
        
        
    }


    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // Gets the header view as a UITableViewHeaderFooterView and changes the text color
        
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor.whiteColor()
        headerView.contentView.backgroundColor = UIColor.darkGrayColor()
        
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 2))
        footerView.backgroundColor = UIColor.darkGrayColor()
        
        return footerView
    }

    
    // MARK:- Functions
    
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
            
            fireBase.saveNewPostInDataBase(imageURL: imageURL, itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: itemPrice, onlinePaymentOption: self.acceptOnlinePaymentSwitch.on, shippingOption: self.willingToShipSwitch.on)
            
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
        
        acceptOnlinePaymentSwitch.on = false
        willingToShipSwitch.on = false
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