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
    
    
    
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var tfAddressLine1: UITextField!
    @IBOutlet weak var imgProfileImage: UIImageView!
    @IBOutlet weak var tfTeamPostcode: UITextField!
    @IBOutlet weak var tfTeamName: UITextField!
    @IBOutlet weak var managerSwitch: UISwitch!
    @IBOutlet weak var tfTeamId: UITextField!
    @IBOutlet weak var tfPostcode: UITextField!
    @IBOutlet weak var tfAddressLine2: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfEmailAddress: UITextField!
    @IBOutlet weak var tfFullName: UITextField!
    @IBOutlet weak var lblSwitchText: UILabel!
    @IBOutlet weak var tfTeamPIN: UITextField!
    @IBOutlet weak var submitConstraint: NSLayoutConstraint!
    
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
        
        setImage()
        
        setTextFields(textfieldName: tfFullName)
        setTextFields(textfieldName: tfEmailAddress)
        setTextFields(textfieldName: tfPassword)
        setTextFields(textfieldName: tfAddressLine1)
        setTextFields(textfieldName: tfAddressLine2)
        setTextFields(textfieldName: tfPostcode)
        setTextFields(textfieldName: tfTeamId)
        setTextFields(textfieldName: tfTeamName)
        setTextFields(textfieldName: tfTeamPostcode)
        setTextFields(textfieldName: tfTeamPIN)
        
        btnCancel.layer.cornerRadius = 5.0
        btnSubmit.layer.cornerRadius = 5.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        fetchTeams ()
        fetchPlayers ()
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= 70
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += 70
            }
        }
    }
    
    func setImage () {
        imgProfileImage.layer.cornerRadius = imgProfileImage.frame.size.width / 2
        imgProfileImage.layer.masksToBounds = true
        
        btnPhoto.layer.cornerRadius = btnPhoto.frame.size.width / 2
        btnPhoto.layer.masksToBounds = true
        let myColor = UIColor.gray
        btnPhoto.layer.borderColor = myColor.cgColor
        btnPhoto.layer.borderWidth = 1.0
    }
    
    func setTextFields (textfieldName : UITextField) {
        let myColor = UIColor.gray
        textfieldName.layer.borderColor = myColor.cgColor
        textfieldName.layer.borderWidth = 1.0
        textfieldName.layer.cornerRadius = 10.0
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
            btnPhoto.setTitle("",for: .normal)
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
            lblSwitchText.text = "I'm creating a team"
            submitConstraint.constant =  60
        } else {
            tfTeamName.isHidden = true
            tfTeamPostcode.isHidden = true
            tfTeamId.isHidden = false
            lblSwitchText.text = "I'm joining a team"
            submitConstraint.constant = 20
        }
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
                            if (tfTeamId.text == tempId && tfTeamPIN.text == String(PIN)) {
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Make sure you add the text field to the delegate
        
        // limit to 4 characters
        let characterCountLimit = 6
        
        // We need to figure out how many characters would be in the string after the change happens
        let startingLength = tfTeamPIN.text?.characters.count ?? 0
        let lengthToAdd = string.characters.count
        let lengthToReplace = range.length
        
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= characterCountLimit
    }
    
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        
        if let photo = imgProfileImage.image, let email = tfEmailAddress.text, let password = tfPassword.text, let fullName = tfFullName.text, let address1 = tfAddressLine1.text, let address2 = tfAddressLine2.text, let postcode = tfPostcode.text, let teamId = tfTeamId.text, let teamName = tfTeamName.text, let teamPostcode = tfTeamPostcode.text, let teamPIN = tfTeamPIN.text {
            
            if self.managerSwitch.isOn {
                //MANAGER MODE
                if fullName == "" || password == "" || email == "" || address1 == "" || address2 == "" || postcode == "" || teamName == "" || teamPostcode == "" || teamPIN == "" {
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
                        self.displayAlert(title: "Team ID / PIN Error", message: "The team does not exist or the PIN does not match the ID supplied. Please contact your manager to get a valid Team ID / PIN")
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













////
////  SignUpViewController.swift
////  TBG
////
////  Created by Kris Reid on 13/11/2017.
////  Copyright © 2017 Kris Reid. All rights reserved.
////
//
//import UIKit
//import FirebaseAuth
//import FirebaseDatabase
//import FirebaseStorage
//
//class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
//
//    @IBOutlet weak var btnPhoto: UIButton!
//    @IBOutlet weak var btnSubmit: UIButton!
//    @IBOutlet weak var btnCancel: UIButton!
//    @IBOutlet weak var tfAddressLine1: UITextField!
//    @IBOutlet weak var imgProfileImage: UIImageView!
//    @IBOutlet weak var tfTeamPostcode: UITextField!
//    @IBOutlet weak var tfTeamName: UITextField!
//    @IBOutlet weak var managerSwitch: UISwitch!
//    @IBOutlet weak var tfTeamId: UITextField!
//    @IBOutlet weak var tfPostcode: UITextField!
//    @IBOutlet weak var tfAddressLine2: UITextField!
//    @IBOutlet weak var tfPassword: UITextField!
//    @IBOutlet weak var tfEmailAddress: UITextField!
//    @IBOutlet weak var tfFullName: UITextField!
//    @IBOutlet weak var tfTeamPIN: UITextField!
//    @IBOutlet weak var lblSwitchText: UILabel!
//
//    var teams : [DataSnapshot] = []
//    var players : [DataSnapshot] = []
//    var teamDictionary: [String:AnyObject] = [:]
//
//    var teamIdExistsInDB = false
//    var teamNameExistsInDB = false
//    var teamPostcodeExistsInDB = false
//    var returns = false
//    var playerEmailExistsinDB = false
//    let delegate = UIApplication.shared.delegate as! AppDelegate
//    var pushToken = ""
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.pushToken = self.delegate.token
//
//        setImage()
//
//        setTextFields(textfieldName: tfFullName)
//        setTextFields(textfieldName: tfEmailAddress)
//        setTextFields(textfieldName: tfPassword)
//        setTextFields(textfieldName: tfAddressLine1)
//        setTextFields(textfieldName: tfAddressLine2)
//        setTextFields(textfieldName: tfPostcode)
//        setTextFields(textfieldName: tfTeamId)
//        setTextFields(textfieldName: tfTeamName)
//        setTextFields(textfieldName: tfTeamPostcode)
//        setTextFields(textfieldName: tfTeamPIN)
//
//        btnCancel.layer.cornerRadius = 5.0
//        btnSubmit.layer.cornerRadius = 5.0
//
//        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//
//        fetchTeams ()
//        fetchPlayers ()
//
//    }
//
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0{
//                // self.view.frame.origin.y -= keyboardSize.height
//                self.view.frame.origin.y -= 40
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y != 0{
//                // self.view.frame.origin.y += keyboardSize.height
//                self.view.frame.origin.y += 40
//            }
//        }
//    }
//
//    func setImage () {
//        imgProfileImage.layer.cornerRadius = imgProfileImage.frame.size.width / 2
//        imgProfileImage.layer.masksToBounds = true
//
//        btnPhoto.layer.cornerRadius = btnPhoto.frame.size.width / 2
//        btnPhoto.layer.masksToBounds = true
//        let myColor = UIColor.gray
//        btnPhoto.layer.borderColor = myColor.cgColor
//        btnPhoto.layer.borderWidth = 1.0
//    }
//
//    func setTextFields (textfieldName : UITextField) {
//        let myColor = UIColor.gray
//        textfieldName.layer.borderColor = myColor.cgColor
//        textfieldName.layer.borderWidth = 1.0
//        textfieldName.layer.cornerRadius = 10.0
//    }
//
//    func fetchTeams () {
//        Database.database().reference().child("Teams").observe(.childAdded, with: { (snapshot) in
//            self.teams.append(snapshot)
//            print("Teams Fetched")
//        })
//    }
//
//    func fetchPlayers () {
//        Database.database().reference().child("Players").observe(.childAdded, with: { (snapshot) in
//            self.players.append(snapshot)
//            print("Players Fetched")
//        })
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        var selectedImageFromPicker: UIImage?
//
//        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
//            selectedImageFromPicker = editedImage
//        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            selectedImageFromPicker = originalImage
//        }
//
//        if let selectedImage = selectedImageFromPicker {
//            imgProfileImage.image = selectedImage
//            btnPhoto.setTitle("",for: .normal)
//        }
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func btnPhotoTapped(_ sender: Any) {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        imagePickerController.allowsEditing = true
//        self.present(imagePickerController, animated: true, completion: nil)
//    }
//
//    @IBAction func managerSwitchTapped(_ sender: Any) {
//        if managerSwitch.isOn {
//            tfTeamName.isHidden = false
//            tfTeamPostcode.isHidden = false
//            tfTeamId.isHidden = true
//            lblSwitchText.text = "I'm creating a team"
//            submitConstraint.constant = 60
//        } else {
//            tfTeamName.isHidden = true
//            tfTeamPostcode.isHidden = true
//            tfTeamId.isHidden = false
//            lblSwitchText.text = "I'm joining a team"
//            submitConstraint.constant = 20
//        }
//    }
//
//    @IBOutlet weak var submitConstraint: NSLayoutConstraint!
//
//
//    func teamNameDBCheck () {
//        for team in self.teams {
//            if let teamDictionary = team.value as? [String:AnyObject] {
//                if let tempName = teamDictionary["Team Name"] as? String {
//                    if teamNameExistsInDB == false {
//                        if (tfTeamName.text == tempName) {
//                            print("Team Name found")
//                            self.teamNameExistsInDB = true
//                        } else {
//                            print("Team Name NOT found")
//                            self.teamNameExistsInDB = false
//                        }
//                    }
//                    else {
//                        //DO NOTHING
//                    }
//                }
//            }
//        }
//    }
//
//    func PostcodeDBCheck () {
//        for team in self.teams {
//            if let teamDictionary = team.value as? [String:AnyObject] {
//                if let tempPostcode = teamDictionary["Team Postcode"] as? String {
//                    if teamPostcodeExistsInDB == false {
//                        if (tfTeamPostcode.text == tempPostcode) {
//                            print("Team Postcode found")
//                            self.teamPostcodeExistsInDB = true
//                        } else {
//                            print("Team Postcode NOT found")
//                            self.teamPostcodeExistsInDB = false
//                        }
//                    } else {
//                        // DO NOTHING
//                    }
//                }
//            }
//        }
//    }
//
//    func teamIdDBCheck () {
//        for team in self.teams {
//            if let teamDictionary = team.value as? [String:AnyObject] {
//                if let tempId = teamDictionary["id"] as? String, let teamPIN = teamDictionary["PIN"] as? String {
//
//                    print("LOVE")
//                    if teamIdExistsInDB == false {
//                        if (tfTeamId.text == tempId) {
////                            if (tfTeamPIN.text == teamPIN) {
////                                print("Team ID found")
////                                self.teamIdExistsInDB = true
////                            } else {
////                                print("PIN did not match")
////                            }
//                        } else {
//                            print("Team ID NOT found")
//                            self.teamIdExistsInDB = false
//                        }
//                    }
//                    else {
//                        // DO NOTHING
//                    }
//                }
//            }
//        }
//    }
//
//
//    @IBAction func btnCancelClicked(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
//
//    }
//
//
//    @IBAction func btnSubmitClicked(_ sender: Any) {
//        // TEAM MODE
//        if self.managerSwitch.isOn {
//
//            print("TEAM MODE")
//
//            guard let photo = imgProfileImage.image, let email = tfEmailAddress.text, let password = tfPassword.text, let fullName = tfFullName.text, let address1 = tfAddressLine1.text, let address2 = tfAddressLine2.text, let postcode = tfPostcode.text, let teamName = tfTeamName.text, let teamPostcode = tfTeamPostcode.text, let teamPIN = tfTeamPIN.text else {
//                self.displayAlert(title: "Missing Information", message: "You must provide information in all of the fields provided.")
//                return
//            }
//
//
//                teamNameDBCheck()
//                PostcodeDBCheck()
//
//                if teamNameExistsInDB && teamPostcodeExistsInDB {
//                    self.displayAlert(title: "Team already exists", message: "The team already exists. Please create a different team or contact your club to get the TeamID.")
//                } else {
//
//                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
//                        if let error = error {
//                            self.displayAlert(title: "Error", message: error.localizedDescription)
//                        } else {
//                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
//                            req?.displayName = "Manager"
//                            req?.commitChanges(completion: nil)
//
//                            if let user = user {
//                                let imageFolder = Storage.storage().reference().child("images")
//                                if let uploadData = UIImageJPEGRepresentation(photo, 0.2) {
//                                    imageFolder.child("\(NSUUID().uuidString).jpg").putData(uploadData, metadata: nil, completion: { (metadata, error) in
//                                        if let error = error {
//                                            self.displayAlert(title: "Error", message: error.localizedDescription)
//                                        }
//                                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString  {
//
//                                            //Add the Team to the DB
//                                            let newRef = Database.database().reference().child("Teams").childByAutoId()
//                                            let newKey = newRef.key
//                                            let TeamDictionary : [String:Any] = ["Team Name": teamName, "PIN": teamPIN, "Team Postcode":teamPostcode, "id": newKey]
//                                            newRef.setValue(TeamDictionary)
//
//                                            //Add the player to the DB
//                                            let playerDictionary : [String:Any] = ["Email": email, "Full Name": fullName, "Address Line 1": address1, "Address Line 2": address2, "Postcode": postcode, "Team ID": newKey, "ProfileImage": profileImageUrl, "Manager": true, "Position":"Defender", "Position Side": "Right", "Active Token": self.pushToken]
//
//                                            Database.database().reference().child("Players").child(user.uid).setValue(playerDictionary)
//
//                                            //Segue back to the login page
//                                            self.performSegue(withIdentifier: "signupSubmitSegue", sender: email)
//                                        }
//                                    })
//                                }
//                            }
//                        }
//                    })
//                }
//            // }
//        } else {
//            //PLAYER MODE
//
//            print("PLAYER MODE")
//
////            if fullName == "" || password == "" || email == "" || address1 == "" || address2 == "" || postcode == "" || teamId == "" || teamPIN == "" {
////                self.displayAlert(title: "Missing Information", message: "You must provide information in all of the fields provided.")
////            } else {
//
//            guard let photo = imgProfileImage.image, let email = tfEmailAddress.text, let password = tfPassword.text, let fullName = tfFullName.text, let address1 = tfAddressLine1.text, let address2 = tfAddressLine2.text, let postcode = tfPostcode.text, let teamId = tfTeamId.text, let teamPIN = tfTeamPIN.text else {
//                self.displayAlert(title: "Missing Information", message: "You must provide information in all of the fields provided.")
//                return
//            }
//
//            print("PLAYER MODE2")
//            self.teamIdDBCheck ()
//
//
//                if teamIdExistsInDB {
//                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
//                        if let error = error {
//                            self.displayAlert(title: "Error", message: (error.localizedDescription))
//                        } else {
//                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
//                            req?.displayName = "Player"
//                            req?.commitChanges(completion: nil)
//
//                            if let user = user {
//                                let imageFolder = Storage.storage().reference().child("images")
//                                if let uploadData = UIImageJPEGRepresentation(photo, 0.2) {
//                                    imageFolder.child("\(NSUUID().uuidString).jpg").putData(uploadData, metadata: nil, completion: { (metadata, error) in
//                                        if let error = error {
//                                            self.displayAlert(title: "Error", message: error.localizedDescription)
//                                        }
//                                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString  {
//
//                                            //Add the player to the DB
//                                            let playerDictionary : [String:Any] = ["Email": user.email!, "Full Name": fullName, "Address Line 1": address1, "Address Line 2": address2, "Postcode": postcode, "Team ID": teamId, "ProfileImage": profileImageUrl, "Manager": false, "Position":"Defender", "Position Side": "Right", "Active Token": self.pushToken]
//
//                                            Database.database().reference().child("Players").child(user.uid).setValue(playerDictionary)
//
//                                            //Segue back to the login page
//                                            self.performSegue(withIdentifier: "signupSubmitSegue", sender: email)
//                                        }
//                                    })
//                                }
//
//
//                            }
//                        }
//                    })
//                } else {
//                    // Team is not in the db so users can't sign up
//                    self.displayAlert(title: "Team ID / PIN Error", message: "The team does not exist or the PIN does not match, please contact your manager to get a valid team and PIN")
//                }
//            // }
//        }
//
//    }
//
//    func displayAlert(title:String, message:String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(alertController, animated: true, completion: nil)
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("IN PREPARE FOR SEGUE")
//        if let email = sender as? String {
//            print("Email captured: \(email)")
//            if let selectVC = segue.destination as? LoginViewController {
//                selectVC.playerEmail = email
//                selectVC.playerPassword = tfPassword.text!
//            }
//        }
//    }
//
//
//    //closes the keyboard when you touch white space
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//
//    //enter button will close the keyboard
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//}
//
