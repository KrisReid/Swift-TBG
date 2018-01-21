//
//  SignUpViewController.swift
//  TBG
//
//  Created by Kris Reid on 13/11/2017.
//  Copyright © 2017 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var tfAddressLine1: UITextField!
    @IBOutlet weak var imgProfileImage: UIImageView!
    @IBOutlet weak var tfTeamPostcode: UITextField!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tfTeamName: UITextField!
    @IBOutlet weak var managerSwitch: UISwitch!
    @IBOutlet weak var tfTeamId: UITextField!
    @IBOutlet weak var tfPostcode: UITextField!
    @IBOutlet weak var tfAddressLine2: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfEmailAddress: UITextField!
    @IBOutlet weak var tfFullName: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var teams : [DataSnapshot] = []
    var players : [DataSnapshot] = []
    var teamDictionary: [String:AnyObject] = [:]
    
    var teamIdExistsInDB = false
    var teamNameExistsInDB = false
    var teamPostcodeExistsInDB = false
    var returns = false
    var playerEmailExistsinDB = false
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var pushToken = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pushToken = self.delegate.token
        
        imgProfileImage.layer.cornerRadius = imgProfileImage.frame.size.width / 2
        imgProfileImage.layer.masksToBounds = true
        
        fetchTeams ()
        fetchPlayers ()
        
    }
    
    func fetchTeams () {
        Database.database().reference().child("Teams").observe(.childAdded, with: { (snapshot) in
            self.teams.append(snapshot)
            print("Teams Fetched")
        })
    }
    
    func fetchPlayers () {
        Database.database().reference().child("Players").observe(.childAdded, with: { (snapshot) in
            self.players.append(snapshot)
            print("Players Fetched")
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            imgProfileImage.image = selectedImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnPhotoTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func managerSwitchTapped(_ sender: Any) {
        if managerSwitch.isOn {
            tfTeamName.isHidden = false
            tfTeamPostcode.isHidden = false
            tfTeamId.isHidden = true
        } else {
            tfTeamName.isHidden = true
            tfTeamPostcode.isHidden = true
            tfTeamId.isHidden = false
        }
    }
    
    func teamNameDBCheck () {
        for team in self.teams {
            if let teamDictionary = team.value as? [String:AnyObject] {
                if let tempName = teamDictionary["Team Name"] as? String {
                    if teamNameExistsInDB == false {
                        if (tfTeamName.text == tempName) {
                            print("Team Name found")
                            self.teamNameExistsInDB = true
                        } else {
                            print("Team Name NOT found")
                            self.teamNameExistsInDB = false
                        }
                    }
                    else {
                        //DO NOTHING
                    }
                }
            }
        }
    }
    
    func PostcodeDBCheck () {
        for team in self.teams {
            if let teamDictionary = team.value as? [String:AnyObject] {
                if let tempPostcode = teamDictionary["Team Postcode"] as? String {
                    if teamPostcodeExistsInDB == false {
                        if (tfTeamPostcode.text == tempPostcode) {
                            print("Team Postcode found")
                            self.teamPostcodeExistsInDB = true
                        } else {
                            print("Team Postcode NOT found")
                            self.teamPostcodeExistsInDB = false
                        }
                    } else {
                        // DO NOTHING
                    }
                }
            }
        }
    }
    
    func teamIdDBCheck () {
        for team in self.teams {
            if let teamDictionary = team.value as? [String:AnyObject] {
                if let tempId = teamDictionary["id"] as? String {
                    if teamIdExistsInDB == false {
                        if (tfTeamId.text == tempId) {
                            print("Team ID found")
                            self.teamIdExistsInDB = true
                        } else {
                            print("Team ID NOT found")
                            self.teamIdExistsInDB = false
                        }
                    }
                    else {
                        // DO NOTHING
                    }
                }
            }
        }
    }
    
    
    
    
    @IBAction func btnSignup(_ sender: Any) {
        guard let photo = imgProfileImage.image, let email = tfEmailAddress.text, let password = tfPassword.text, let fullName = tfFullName.text, let address1 = tfAddressLine1.text, let address2 = tfAddressLine2.text, let postcode = tfPostcode.text, let teamId = tfTeamId.text, let teamName = tfTeamName.text, let teamPostcode = tfTeamPostcode.text else {
            print("Something is missing?")
            return
        }
        if self.managerSwitch.isOn {
            //MANAGER MODE
            if fullName == "" || password == "" || email == "" || address1 == "" || address2 == "" || postcode == "" || teamName == "" || teamPostcode == "" {
                self.displayAlert(title: "Missing Information", message: "You must provide information in all of the fields provided.")
            } else {
                
                teamNameDBCheck()
                PostcodeDBCheck()
                
                if teamNameExistsInDB && teamPostcodeExistsInDB {
                    self.displayAlert(title: "Team already exists", message: "The team already exists. Please create a different team or contact your club to get the TeamID.")
                } else {
                    
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        if let error = error {
                            self.displayAlert(title: "Error", message: error.localizedDescription)
                        } else {
                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
                            req?.displayName = "Manager"
                            req?.commitChanges(completion: nil)
                            
                            if let user = user {
                                let imageFolder = Storage.storage().reference().child("images")
                                if let uploadData = UIImageJPEGRepresentation(photo, 0.2) {
                                    imageFolder.child("\(NSUUID().uuidString).jpg").putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                        if let error = error {
                                            self.displayAlert(title: "Error", message: error.localizedDescription)
                                        }
                                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString  {
                                            
                                            //Add the Team to the DB
                                            let newRef = Database.database().reference().child("Teams").childByAutoId()
                                            let newKey = newRef.key
                                            let TeamDictionary : [String:Any] = ["Team Name": teamName, "Team Postcode":teamPostcode, "id": newKey]
                                            newRef.setValue(TeamDictionary)
                                            
                                            //Add the player to the DB
                                            let playerDictionary : [String:Any] = ["Email": email, "Full Name": fullName, "Address Line 1": address1, "Address Line 2": address2, "Postcode": postcode, "Team ID": newKey, "ProfileImage": profileImageUrl, "Manager": true, "Position":"Defender", "Position Side": "Right", "Active Token": self.pushToken]
                                            
                                            Database.database().reference().child("Players").child(user.uid).setValue(playerDictionary)
                                            
                                            //Segue back to the login page
                                            self.performSegue(withIdentifier: "signupSubmitSegue", sender: email)
                                        }
                                    })
                                }
                            }
                        }
                    })
                }
            }
        } else {
            //PLAYER MODE
            self.teamIdDBCheck ()
            
            if fullName == "" || password == "" || email == "" || address1 == "" || address2 == "" || postcode == "" || teamId == "" {
                self.displayAlert(title: "Missing Information", message: "You must provide information in all of the fields provided.")
            } else {
                if teamIdExistsInDB {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        if let error = error {
                            self.displayAlert(title: "Error", message: (error.localizedDescription))
                        } else {
                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
                            req?.displayName = "Player"
                            req?.commitChanges(completion: nil)
                            
                            if let user = user {
                                let imageFolder = Storage.storage().reference().child("images")
                                if let uploadData = UIImageJPEGRepresentation(photo, 0.2) {
                                    imageFolder.child("\(NSUUID().uuidString).jpg").putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                        if let error = error {
                                            self.displayAlert(title: "Error", message: error.localizedDescription)
                                        }
                                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString  {
                                            
                                            //Add the player to the DB
                                            let playerDictionary : [String:Any] = ["Email": user.email!, "Full Name": fullName, "Address Line 1": address1, "Address Line 2": address2, "Postcode": postcode, "Team ID": teamId, "ProfileImage": profileImageUrl, "Manager": false, "Position":"Defender", "Position Side": "Right", "Active Token": self.pushToken]
                                            
                                            Database.database().reference().child("Players").child(user.uid).setValue(playerDictionary)
                                            
                                            //Segue back to the login page
                                            self.performSegue(withIdentifier: "signupSubmitSegue", sender: email)
                                        }
                                    })
                                }
                                
                                
                            }
                        }
                    })
                } else {
                    // Team is not in the db so users can't sign up
                    self.displayAlert(title: "Team ID Error", message: "The team does not exist, please contact your manager to get a valid team")
                }
            }
        }
        

    }
    
    func displayAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("IN PREPARE FOR SEGUE")
        if let email = sender as? String {
            print("Email captured: \(email)")
            if let selectVC = segue.destination as? LoginViewController {
                selectVC.playerEmail = email
                selectVC.playerPassword = tfPassword.text!
            }
        }
    }
    
    
    //closes the keyboard when you touch white space
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //enter button will close the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

