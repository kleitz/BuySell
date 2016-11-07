//
//  EditProfileTableViewController.swift
//  esell
//
//  Created by Angela Lin on 11/7/16.
//  Copyright © 2016 Angela Lin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    
    let fireBase = FirebaseManager()

    
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var emailDescription: UILabel!
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var locationText: UITextField!
    
    
    
    @IBAction func editImageButton(sender: UIButton) {
        
        selectImageFromPhotos()
        
    }
    
    
    // Data to be passed in from Segue
    var profileImage = UIImage() { didSet{ print("image was cahnged..") } }
    var profileName = ""

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationItem.title = "Edit Profile"
        
        tableView.separatorStyle = .None
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(clickSave(_:)))
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(clickCancel(_:)))
        
        self.navigationItem.setRightBarButtonItem(editButton, animated: true)
        self.navigationItem.setLeftBarButtonItem(cancelButton, animated: true)
        
        
        // set Text fields UI
        
        locationLabel.hidden = true
        locationText.hidden = true
        
        emailLabel.hidden = true
        emailDescription.hidden = true
        emailText.hidden = true
        
        
        // set Data passed in from Segue
        
        nameText.text = profileName
    
        
        // PROFILE IMAGE HANDLING
        // set segued image as default
        self.userImage.image = self.profileImage
        self.userImage.contentMode = .ScaleAspectFill
        self.roundUIView(self.userImage, cornerRadiusParams: self.userImage.frame.size.width / 2)

        
        
        // get Email from firebase
        
        let defaults = NSUserDefaults.standardUserDefaults()
        guard let uid = defaults.stringForKey("uid") else {
            print("Failed getting uid out of defaults")
            return
        }
        
        // look up email data from Firebase
        
        fireBase.lookupSingleUser(userID: uid) { (getUser) in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.emailText.text = getUser.email

            }

        }
     
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }

    
    
    func clickSave(button: UIBarButtonItem)
    {
        
        // NEED OT MAKE SURE NOTHING BLANK
        print("\n---  clickSave")
        
        guard let updatedName = nameText.text where updatedName != "" else {
            popupNotifyIncomplete("Name cannot be left blank")
            return
        }
        
        guard let updatedEmail = emailText.text where updatedEmail != "" else {
            popupNotifyIncomplete("Email cannot be left blank")
            return
        }
        
    
        // update FIRuser profile
        
        let user = FIRAuth.auth()?.currentUser
        
        guard let uid = user?.uid else {
            print("error no UID")
            return
        }

        
        // START UPDATE
        
        if let user = user {
            let changeRequest = user.profileChangeRequest()
            changeRequest.displayName = updatedName
           
            changeRequest.commitChangesWithCompletion { error in
                if let error = error {
                    print("ERROR \(error.localizedDescription)")
                    // An error happened.
                } else {
                    print(" >> FIR user profile updated")
                    // Profile updated.
                    
                    for profile in user.providerData {
                        let providerID = profile.providerID
                        print("   providerID \(providerID)") // "password" instead of "facebook.com"
    
                        let name = profile.displayName
                        print("   name \(name)")
                        
                        let email = profile.email
                        print("   email \(email)")
                        
                        let photoURL = profile.photoURL
                        print("   photoURL \(photoURL)")
                    }

                }
            }
        }
        
        user?.updateEmail(updatedEmail) { error in
            if let error = error {
                // An error happened.
                print("ERROR email update: \(error.localizedDescription)")
            } else {
                // Email updated.
                print(" >> Email updated")
            }
        }
        
        // NEED TO DO THE IMAGE SAVING
        
        guard let updatedImage = userImage.image else {
            print("error")
            return
        }
        
        guard let imageData = updatedImage.lowestQualityJPEGNSData else {
            print("error with imageData")
            return
        }
        
        print("imageData length: \(imageData.length)")
        
        
        // Create STORAGE ref for images only (not database reference)
        
        let imageName = NSUUID().UUIDString
        
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://buysell-b6e74.appspot.com")
        let imagesRef = storageRef.child("user_images").child("\(imageName).png")
        
        // After checking is ok, store in storage (the image gets its own url)
        
        imagesRef.putData(imageData, metadata: nil) { (metadata, error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            print(metadata)
            
            guard let imageURL = metadata?.downloadURL()?.absoluteString else {
                print("unable to get imageURL")
                return
            }
            
            
            // Actual save happens in a separate function, after the checking
            // SAVE IN FIREBASE
            self.fireBase.updateUserInfo(uid, name: updatedName, email: updatedEmail, imageURL: imageURL)
            
            // SAVE IN NSUSERDEFATULS
            let defaults = NSUserDefaults.standardUserDefaults()
            
            defaults.setValue(updatedName, forKey: "userName")
            defaults.setValue(imageURL, forKey: "userImageURL")
            
            
            self.popupNotifySaved("Your profile is updated")
            
        }
    }
    
    
    func clickCancel(button: UIBarButtonItem)
    {
        print("clickCnacnel")
        self.performSegueWithIdentifier("unwindToProfile", sender: self)
    }
    
    
    
    // MARK:- ImagePicker
    
    func selectImageFromPhotos() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            print(" > clicked to selectImage")
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: ImagePicker Delegate Methods
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        print("   > canceled selectImage")
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        print("   > completed selectImage")
        
        guard let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("ERROR")
            return
        }
        
        
        // set new image from Photos
        self.userImage.image = chosenImage
        self.userImage.contentMode = .ScaleAspectFill
        
        self.roundUIView(self.userImage, cornerRadiusParams: self.userImage.frame.size.width / 2)
        
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }

    func popupNotifyIncomplete(errorMessage: String){
        
        let alertController = UIAlertController(title: "Wait!", message:
            errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil ))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func popupNotifySaved(errorMessage: String){
        
        let alertController = UIAlertController(title: "Save Complete", message:
            errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,
            handler: { action in
                self.performSegueWithIdentifier("unwindToProfile", sender: self)
        } ))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    private func roundUIView(view: UIView, cornerRadiusParams: CGFloat!) {
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadiusParams
    }

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            
            switch identifier {
                
            case "unwindToProfile":
                
                guard let profileVC = segue.destinationViewController as? ProfileTableViewController else {
                    print("segue fail get ref to next controller")
                    return
                }
                
                profileVC.loadUserInfo()
            
            default: break
            }
        }
    }
    
    
    deinit{
        print(" >>  deinit Killed EditProfile")
    }
    
}

extension UIImage {
    var uncompressedPNGData: NSData?      { return UIImagePNGRepresentation(self)        }
    var highestQualityJPEGNSData: NSData? { return UIImageJPEGRepresentation(self, 1.0)  }
    var highQualityJPEGNSData: NSData?    { return UIImageJPEGRepresentation(self, 0.75) }
    var mediumQualityJPEGNSData: NSData?  { return UIImageJPEGRepresentation(self, 0.5)  }
    var lowQualityJPEGNSData: NSData?     { return UIImageJPEGRepresentation(self, 0.25) }
    var lowestQualityJPEGNSData:NSData?   { return UIImageJPEGRepresentation(self, 0.0)  }
}
