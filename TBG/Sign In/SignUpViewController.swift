//
//  SignUpViewController.swift
//  TBG
//
//  Created by Kris Reid on 12/04/2019.
//  Copyright © 2019 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    @IBOutlet weak var svCredentials: UIScrollView!
    @IBOutlet weak var vCredentials: UIView!
    @IBOutlet weak var btnMoveToPersonalDetails: UIButton!
    @IBOutlet weak var btnCancelForm: UIButton!
    @IBOutlet weak var btnProfilePicture: UIButton!
    @IBOutlet weak var ivProfilePicture: UIImageView!
    @IBOutlet weak var tfFullName: UITextField!
    @IBOutlet weak var tfEmailAddress: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfAddressLineOne: UITextField!
    @IBOutlet weak var tfAddressLineTwo: UITextField!
    @IBOutlet weak var tfAddressPostcode: UITextField!
    
    @IBOutlet weak var vTeamDetails: UIView!
    @IBOutlet weak var btnBackToCredentials :UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var swManager: UISwitch!
    @IBOutlet weak var lblManager: UILabel!
    @IBOutlet weak var tfTeamID: UITextField!
    @IBOutlet weak var tfTeamPIN: UITextField!
    @IBOutlet weak var tfTeamName: UITextField!
    @IBOutlet weak var tfTeamPostcode: UITextField!
    
    
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
    let activityIndicator = UIActivityIndicatorView(frame:CGRect(x: 0, y: 0, width: 150, height: 150))
    
    
    override func viewDidLoad() {
        
        self.pushToken = self.delegate.token
        
        //Set the containers
        setContainer(container: vCredentials, leftButton: btnCancelForm, rightButton: btnMoveToPersonalDetails);
        setContainer(container: vTeamDetails, leftButton: btnBackToCredentials, rightButton: btnSubmit);
        
        
        //Setting the ScrollView for Page 1
        svCredentials.frame = CGRect(x: 0 , y: 0, width: vCredentials.frame.width, height: vCredentials.frame.height - 50)
        svCredentials.contentSize.height = vCredentials.frame.height
        svCredentials.contentSize.width = vCredentials.frame.width
        
        //Set the image for Page 1
        setImage()
        
        //Set the switch for page 2
        swManager.center = CGPoint(x: vCredentials.frame.width / 2, y: 50)
        lblManager.center = CGPoint(x: vCredentials.frame.width / 2, y: 80)
        
        //Set the TextFields
        setTextFields (textfieldName: tfFullName, view: vCredentials, yCoordinate: 210, placeholder: "Full Name")
        setTextFields (textfieldName: tfEmailAddress, view: vCredentials, yCoordinate: 260, placeholder: "Email Address")
        setTextFields (textfieldName: tfPassword, view: vCredentials, yCoordinate: 310, placeholder: "Password")
        setTextFields (textfieldName: tfAddressLineOne, view: vCredentials, yCoordinate: 360, placeholder: "Address Line 1")
        setTextFields (textfieldName: tfAddressLineTwo, view: vCredentials, yCoordinate: 410, placeholder: "Address Line 2")
        setTextFields (textfieldName: tfAddressPostcode, view: vCredentials, yCoordinate: 460, placeholder: "Postcode")
        
        setTextFields (textfieldName: tfTeamPIN, view: vTeamDetails, yCoordinate: 160, placeholder: "Team PIN (6 digit code)")
        setTextFields (textfieldName: tfTeamID, view: vTeamDetails, yCoordinate: 210, placeholder: "Team ID")
        setTextFields (textfieldName: tfTeamName, view: vTeamDetails, yCoordinate: 210, placeholder: "Team Name")
        setTextFields (textfieldName: tfTeamPostcode, view: vTeamDetails, yCoordinate: 260, placeholder: "Team Postcode")
        
        //Keyboard show and dismiss observers
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        fetchTeams()
        fetchPlayers()
        
    }
    
    
    //CREDENTIALS
    @IBAction func btnCancelFormClicked(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func btnMoveToPersonalDetailsClicked(_ sender: Any) {
        vCredentials.isHidden = true
        vTeamDetails.isHidden = false
    }
    
    @IBAction func btnProfilePictureClicked(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func setImage () {
        ivProfilePicture.layer.cornerRadius = ivProfilePicture.frame.size.width / 2
        ivProfilePicture.layer.masksToBounds = true
        ivProfilePicture.center = CGPoint(x: vCredentials.frame.width / 2, y: 100)
        
        btnProfilePicture.layer.cornerRadius = btnProfilePicture.frame.size.width / 2
        btnProfilePicture.layer.masksToBounds = true
        let myColor = UIColor.white
        btnProfilePicture.layer.borderColor = myColor.cgColor
        btnProfilePicture.layer.borderWidth = 1.0
        btnProfilePicture.center = CGPoint(x: vCredentials.frame.width / 2, y: 100)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            ivProfilePicture.image = selectedImage
            btnProfilePicture.setTitle("",for: .normal)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //TEAM DETAILS
    @IBAction func btnBackToCredentialsClicked(_ sender: Any) {
        vTeamDetails.isHidden = true
        vCredentials.isHidden = false
    }
    
    func teamNameDBCheck () {
        self.teamNameExistsInDB = false
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
        self.teamPostcodeExistsInDB = false
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
        self.teamIdExistsInDB = false
        for team in self.teams {
            print("loopy")
            if let teamDictionary = team.value as? [String:AnyObject] {
                if let tempId = teamDictionary["id"] as? String {
                    if let PIN = teamDictionary["PIN"] as? Int {
                        if teamIdExistsInDB == false {
                            if (tfTeamID.text == tempId && tfTeamPIN.text == String(PIN)) {
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
    }

    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        print("Submit Clicked")
        
        if let photo = ivProfilePicture.image, let email = tfEmailAddress.text, let password = tfPassword.text, let fullName = tfFullName.text, let address1 = tfAddressLineOne.text, let address2 = tfAddressLineTwo.text, let postcode = tfAddressPostcode.text, let teamId = tfTeamID.text, let teamName = tfTeamName.text, let teamPostcode = tfTeamPostcode.text, let teamPIN = tfTeamPIN.text {
            
            if self.swManager.isOn {
                //MANAGER MODE
                if fullName == "" || password == "" || email == "" || address1 == "" || address2 == "" || postcode == "" || teamName == "" || teamPostcode == "" || teamPIN == "" {
                    self.displayAlert(title: "Missing Information", message: "You must provide information in all of the fields provided.")
                    
                } else {
                    
                    teamNameDBCheck()
                    PostcodeDBCheck()
                    
                    if teamNameExistsInDB && teamPostcodeExistsInDB {
//                        stopSpinner()
                        self.displayAlert(title: "Team already exists", message: "The team already exists. Please create a different team or contact your club to get the TeamID.")
                    } else {
                        
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if let error = error {
                                self.displayAlert(title: "Error", message: error.localizedDescription)
                            } else {
//                                self.startSpinner()
                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                req?.displayName = "Manager"
                                req?.commitChanges(completion: nil)
                                
                                if let user = user {
                                    let imageFolder = Storage.storage().reference().child("images")
                                    if let uploadData = photo.jpegData(compressionQuality: 0.2) {
                                        imageFolder.child("\(NSUUID().uuidString).jpg").putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                            if let error = error {
                                                self.displayAlert(title: "Error", message: error.localizedDescription)
                                            }
                                            if let profileImageUrl = metadata?.downloadURL()?.absoluteString  {
                                                
                                                //Add the Team to the DB
                                                let newRef = Database.database().reference().child("Teams").childByAutoId()
                                                let newKey = newRef.key
                                                let TeamDictionary : [String:Any] = ["Team Name": teamName, "PIN": teamPIN, "Team Postcode":teamPostcode, "id": newKey]
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
                
                if fullName == "" || password == "" || email == "" || address1 == "" || address2 == "" || postcode == "" || teamId == "" || teamPIN == "" {
                    self.displayAlert(title: "Missing Information", message: "You must provide information in all of the fields provided.")
                } else {
                    if teamIdExistsInDB {
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if let error = error {
                                self.displayAlert(title: "Error", message: (error.localizedDescription))
                            } else {
//                                self.startSpinner()
                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                req?.displayName = "Player"
                                req?.commitChanges(completion: nil)
                                
                                if let user = user {
                                    let imageFolder = Storage.storage().reference().child("images")
                                    if let uploadData = photo.jpegData(compressionQuality: 0.2) {
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
                        self.displayAlert(title: "Team ID / PIN Error", message: "The team does not exist or the PIN does not match the ID supplied. Please contact your manager to get a valid Team ID / PIN")
                    }
                }
            }
        } else {
            self.displayAlert(title: "Missing Photo", message: "You must provide a picture of yourself to sign up.")
        }
    }
    
    
    @IBAction func swManagerClicked(_ sender: Any) {
        if swManager.isOn {
            tfTeamName.isHidden = false
            tfTeamPostcode.isHidden = false
            tfTeamID.isHidden = true
            lblManager.text = "I'm creating a team"
//            submitConstraint.constant =  60
        } else {
            tfTeamName.isHidden = true
            tfTeamPostcode.isHidden = true
            tfTeamID.isHidden = false
            lblManager.text = "I'm joining a team"
//            submitConstraint.constant = 20
        }
    }
    
    
    
    //GENERAL FUNCTIONS
    func setContainer (container: UIView, leftButton: UIButton, rightButton:UIButton) {
        //SET THE CONTAINER
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.cgColor
        container.layer.cornerRadius = 10
        container.frame = CGRect(x: 0 , y: 0, width: UIScreen.main.bounds.height / 2.5, height: UIScreen.main.bounds.height / 1.5)
        container.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        
        //CANCEL BUTTON
        leftButton.layer.borderWidth = 1
        leftButton.layer.borderColor = UIColor.white.cgColor
        leftButton.layer.cornerRadius = CGFloat(10)
        leftButton.clipsToBounds = true
        leftButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        let cancelY = container.frame.height - (leftButton.frame.height)
        leftButton.frame = CGRect(x: 0, y: cancelY, width: container.frame.width/2, height: 50)
        
        //SUBMIT BUTTON
        rightButton.layer.borderWidth = 1
        rightButton.layer.borderColor = UIColor.white.cgColor
        rightButton.layer.cornerRadius = CGFloat(10)
        rightButton.clipsToBounds = true
        rightButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
        let submitX = container.frame.width / 2 - 1
        let submitY = container.frame.height - rightButton.frame.height
        rightButton.frame = CGRect(x: submitX, y: submitY, width: container.frame.width/2 + 1, height: 50)
    }
    
    
    func setTextFields (textfieldName: UITextField, view: UIView, yCoordinate: CGFloat, placeholder: String) {
        let myColor = UIColor.white
        textfieldName.layer.borderColor = myColor.cgColor
        textfieldName.layer.borderWidth = 1.0
        textfieldName.layer.cornerRadius = 10.0
        textfieldName.frame = CGRect(x: 0 , y: yCoordinate, width: view.frame.width / 1.2, height: 30)
        textfieldName.center = CGPoint(x: view.frame.width / 2, y: yCoordinate)
        textfieldName.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= 110
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += 110
            }
        }
    }
    
    //closes the keyboard when you touch white space in outer view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    func displayAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        stopSpinner()
        if let email = sender as? String {
            print("Email captured: \(email)")
            if let selectVC = segue.destination as? LoginViewController {
                selectVC.playerEmail = email
                selectVC.playerPassword = tfPassword.text!
            }
        }
    }
    
//    func startSpinner() {
//        //MARK: Spinner
//        print("START SPINNER CALLED")
//        self.vLoading.isHidden = false
//        self.activityIndicator.center = self.view.center
//        self.activityIndicator.hidesWhenStopped = true
//        self.activityIndicator.style = UIActivityIndicatorView.Style.gray
//        view.addSubview(self.activityIndicator)
//        self.activityIndicator.startAnimating()
//        UIApplication.shared.beginIgnoringInteractionEvents()
//    }
//
//    func stopSpinner() {
//        print("STOP SPINNER CALLED")
//        self.vLoading.isHidden = true
//        self.activityIndicator.stopAnimating()
//        UIApplication.shared.endIgnoringInteractionEvents()
//    }
    
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }

}
