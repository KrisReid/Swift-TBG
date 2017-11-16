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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgProfileImage.layer.cornerRadius = imgProfileImage.frame.size.width / 2
        imgProfileImage.layer.masksToBounds = true

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgProfileImage.image = image
        } else {
            print("There was an error picking the Image")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnPhotoTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = false
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
    
    @IBAction func btnSignup(_ sender: Any) {
        if let email = tfEmailAddress.text {
            if let password = tfPassword.text {
                if let fullName = tfFullName.text {
                    if let address1 = tfAddressLine1.text {
                        if let address2 = tfAddressLine2.text {
                            if let postcode = tfPostcode.text {
                                if let teamId = tfTeamId.text {
                                    if let teamName = tfTeamName.text {
                                        if let teamPostcode = tfTeamPostcode.text {
                                            if managerSwitch.isOn {
                                                //manager switch is on
                                                if fullName == "" || password == "" || email == "" || address1 == "" || address2 == "" || postcode == "" || teamName == "" || teamPostcode == "" {
                                                    displayAlert(title: "Missing Information", message: "You must provide information in all of the fields provided.")
                                                } else {
                                                    //Create a user in Auth
                                                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                                                        if error != nil {
                                                            self.displayAlert(title: "Error", message: error!.localizedDescription)
                                                        } else {
                                                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                                            //req?.displayName = fullName
                                                            req?.commitChanges(completion: nil)
                                                        }
                                                    })
                                                    
                                                    //Create a team and player in the DB and assign teamId to the player

                                                    
                                                    // Create a team in firebase and store the autoId of firebase in a variable called key
                                                    let newRef = Database.database().reference().child("Teams").childByAutoId()
                                                    let key = newRef.key
                                                    let TeamDictionary : [String:Any] = ["Team Name": teamName, "Team Postcode":teamPostcode, "id": key]
                                                    newRef.setValue(TeamDictionary)
                                                    
                                                    
                                                    // Create a player dictionary using the key to store against the Team ID
                                                    let playerDictionary : [String:Any] = ["Email": email, "Full Name": fullName, "Address Line 1": address1, "Address Line 2": address2, "Postcode": postcode, "Team ID": key, "Team Name": teamName, "Team Postcode":teamPostcode]
                                                   
                                                    // Create the player in firebase
                                                    Database.database().reference().child("Players").childByAutoId().setValue(playerDictionary)
                                                    
                                                    //Segue back to the login page
                                                    self.performSegue(withIdentifier: "signupSubmitSegue", sender: nil)
                                                }
                                            } else {
                                                //manager switch is off
                                                if fullName == "" || password == "" || email == "" || address1 == "" || address2 == "" || postcode == "" || teamId == "" {
                                                    displayAlert(title: "Missing Information", message: "You must provide information in all of the fields provided.")
                                                } else {
                                                    //Create a user in Auth
                                                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                                                        if error != nil {
                                                            self.displayAlert(title: "Error", message: error!.localizedDescription)
                                                        } else {
                                                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                                            //req?.displayName = fullName
                                                            req?.commitChanges(completion: nil)
                                                        }
                                                    })
                                                    
                                                    //Add the player to the DB
                                                    let playerDictionary : [String:Any] = ["Email": email, "Full Name": fullName, "Address Line 1": address1, "Address Line 2": address2, "Postcode": postcode, "Team ID": teamId]
                                                    Database.database().reference().child("Players").childByAutoId().setValue(playerDictionary)
                                                    
                                                    self.performSegue(withIdentifier: "signupSubmitSegue", sender: nil)
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
