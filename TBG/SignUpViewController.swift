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

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    var teamIdExistsInDB = false
    var teamNameExistsInDB = false
    var teamPostcodeExistsInDB = false
    
    var playerEmailExistsinDB = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgProfileImage.layer.cornerRadius = imgProfileImage.frame.size.width / 2
        imgProfileImage.layer.masksToBounds = true
        
        fetchTeams ()
        fetchPlayers ()
        
    }
    
    func fetchTeams () {
        Database.database().reference().child("Teams").observe(.childAdded, with: { (snapshot) in
            self.teams.append(snapshot)
        })
    }
    
    func fetchPlayers () {
        Database.database().reference().child("Players").observe(.childAdded, with: { (snapshot) in
            self.players.append(snapshot)
            
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
    
    func playerEmailDBCheck () {
        for player in self.players {
            
            if let playerDictionary = player.value as? [String:AnyObject] {
                if let tempEmail = playerDictionary["Email"] as? String {
                    if playerEmailExistsinDB == false {
                        if (tfEmailAddress.text == tempEmail) {
                            print("Player Email found")
                            self.playerEmailExistsinDB = true
                        } else {
                            print("Player Email NOT found")
                            self.playerEmailExistsinDB = false
                        }
                    } else {
                        // DO NOTHING
                    }
                }
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    
    @IBAction func btnSignup(_ sender: Any) {
        if let photo = imgProfileImage.image {
            if let email = tfEmailAddress.text {
                if let password = tfPassword.text {
                    if let fullName = tfFullName.text {
                        if let address1 = tfAddressLine1.text {
                            if let address2 = tfAddressLine2.text {
                                if let postcode = tfPostcode.text {
                                    if let teamId = tfTeamId.text {
                                        if let teamName = tfTeamName.text {
                                            if let teamPostcode = tfTeamPostcode.text {
                                                
                                                if self.managerSwitch.isOn {
                                                    //MANAGER MODE
                                                    if fullName == "" || password == "" || email == "" || address1 == "" || address2 == "" || postcode == "" || teamName == "" || teamPostcode == "" {
                                                        self.displayAlert(title: "Missing Information", message: "You must provide information in all of the fields provided.")
                                                    } else {
                                                        
                                                        teamNameDBCheck()
                                                        PostcodeDBCheck()
                                                        playerEmailDBCheck()
                                                        let isemailValid = isValidEmail (email)
                                                        
                                                        if playerEmailExistsinDB {
                                                            self.displayAlert(title: "Email already registered", message: "This email address already exists.")
                                                        } else {
                                                            if teamNameExistsInDB && teamPostcodeExistsInDB {
                                                                self.displayAlert(title: "Team already exists", message: "The team already exists. Please create a different team or contact your club to get the TeamID.")
                                                            } else {
                                                                if isemailValid {
                                                                    //Create a user in Auth
                                                                    print("-------Auth Start-------")
                                                                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                                                                        if error != nil {
                                                                            self.displayAlert(title: "Error", message: error!.localizedDescription)
                                                                        } else {
                                                                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                                                            req?.displayName = "Manager"
                                                                            req?.commitChanges(completion: nil)
                                                                        }
                                                                    })
                                                                    print("-------Auth End-------")
                                                                    
                                                                    //STORING IMAGES AND CREATING DATABASE ENTRIES
                                                                    let imageName = NSUUID().uuidString
                                                                    
                                                                    let storageRef = Storage.storage().reference().child("\(imageName).png")
                                                                    
                                                                    if let uploadData = UIImagePNGRepresentation(photo) {
                                                                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                                                            if error != nil {
                                                                                print(error)
                                                                                return
                                                                            }
                                                                            if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                                                                                print("-------Team Creation Start-------")
                                                                                let newRef = Database.database().reference().child("Teams").childByAutoId()
                                                                                let newKey = newRef.key
                                                                                let TeamDictionary : [String:Any] = ["Team Name": teamName, "Team Postcode":teamPostcode, "id": newKey]
                                                                                newRef.setValue(TeamDictionary)
                                                                                print("-------Team Creation End-------")
                                                                                
                                                                                // Create a player dictionary using the key to store against the Team ID
                                                                                print("-------Player Creation Start-------")
                                                                                let playerDictionary : [String:Any] = ["Email": email, "Full Name": fullName, "Address Line 1": address1, "Address Line 2": address2, "Postcode": postcode, "Team ID": newKey, "ProfileImage": profileImageUrl, "Manager": true]
                                                                                Database.database().reference().child("Players").childByAutoId().setValue(playerDictionary)
                                                                                print("-------Player Creation End-------")
                                                                                
                                                                                //Segue back to the login page
                                                                                self.performSegue(withIdentifier: "signupSubmitSegue", sender: nil)
                                                                            }
                                                                        })
                                                                    }
                                                                    
                                                                } else {
                                                                    self.displayAlert(title: "Invalid email", message: "This does not comply with a valid email address.")
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    //PLAYER MODE
                                                    if fullName == "" || password == "" || email == "" || address1 == "" || address2 == "" || postcode == "" || teamId == "" {
                                                        self.displayAlert(title: "Missing Information", message: "You must provide information in all of the fields provided.")
                                                    } else {
                                                        
                                                        self.playerEmailDBCheck()
                                                        self.teamIdDBCheck ()
                                                        let isemailValid = isValidEmail (email)
                                                        
                                                        if playerEmailExistsinDB {
                                                            self.displayAlert(title: "Email already registered", message: "This email address already exists.")
                                                        } else {
                                                            if teamIdExistsInDB == false {
                                                                self.displayAlert(title: "Invalid Team ID", message: "Please contact your manager to get a valid team ID")
                                                            } else {
                                                                if isemailValid {
                                                                    //Create a user in Auth
                                                                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                                                                        if error != nil {
                                                                            self.displayAlert(title: "Error", message: error!.localizedDescription)
                                                                        } else {
                                                                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                                                            req?.displayName = "Player"
                                                                            req?.commitChanges(completion: nil)
                                                                        }
                                                                    })
                                                                    
                                                                    //STORING IMAGES AND CREATING DATABASE ENTRIES
                                                                    let imageName = NSUUID().uuidString
                                                                    
                                                                    let storageRef = Storage.storage().reference().child("\(imageName).png")
                                                                    
                                                                    if let uploadData = UIImagePNGRepresentation(photo) {
                                                                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                                                            if error != nil {
                                                                                print(error)
                                                                                return
                                                                            }
                                                                            if let profileImageUrl = metadata?.downloadURL()?.absoluteString  {
                                                                                //Add the player to the DB
                                                                                let playerDictionary : [String:Any] = ["Email": email, "Full Name": fullName, "Address Line 1": address1, "Address Line 2": address2, "Postcode": postcode, "Team ID": teamId, "ProfileImage": profileImageUrl, "Manager": false]
                                                                                
                                                                                Database.database().reference().child("Players").childByAutoId().setValue(playerDictionary)
                                                                            }
                                                                        })
                                                                    }
                                                                    //Segue back to the login page
                                                                    self.performSegue(withIdentifier: "signupSubmitSegue", sender: nil)
                                                                    
                                                                } else {
                                                                    self.displayAlert(title: "Invalid email", message: "This does not comply with a valid email address.")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func displayAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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

