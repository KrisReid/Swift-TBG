//
//  AlternativeSignUpViewController.swift
//  TBG
//
//  Created by Kris Reid on 12/04/2019.
//  Copyright © 2019 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AlternativeSignUpViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    @IBOutlet weak var svCredentials: UIScrollView!
    @IBOutlet weak var vCredentials: UIView!
    @IBOutlet weak var btnMoveToPersonalDetails: UIButton!
    @IBOutlet weak var btnCancelForm: UIButton!
    @IBOutlet weak var btnProfilePicture: UIButton!
    @IBOutlet weak var ivProfilePicture: UIImageView!
    @IBOutlet weak var tfFullName: UITextField!
    @IBOutlet weak var tfEmailAddress: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    
    @IBOutlet weak var vPersonalDetails: UIView!
    @IBOutlet weak var btnBackToCredentials: UIButton!
    @IBOutlet weak var btnMoveToSubmit: UIButton!
    @IBOutlet weak var tfAddressLineOne: UITextField!
    @IBOutlet weak var tfAddressLineTwo: UITextField!
    @IBOutlet weak var tfAddressPostcode: UITextField!
    
    
    
    @IBOutlet weak var vTeamDetails: UIView!
    @IBOutlet weak var btnBackToPersonalDetails: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    
    
    override func viewDidLoad() {
        
        
        setContainer(container: vCredentials, leftButton: btnCancelForm, rightButton: btnMoveToPersonalDetails);
        setContainer(container: vPersonalDetails, leftButton: btnBackToCredentials, rightButton: btnMoveToSubmit);
        setContainer(container: vTeamDetails, leftButton: btnBackToPersonalDetails, rightButton: btnSubmit);
        
        
        
        svCredentials.frame = CGRect(x: 0 , y: 0, width: vCredentials.frame.width, height: vCredentials.frame.height - 50)
        svCredentials.contentSize.height = vCredentials.frame.height
        svCredentials.contentSize.width = vCredentials.frame.width
        
        
        
        setImage()
        
        
        
        setTextFields (textfieldName: tfFullName, view: vCredentials, yCoordinate: 210, placeholder: "Full Name")
        setTextFields (textfieldName: tfEmailAddress, view: vCredentials, yCoordinate: 260, placeholder: "Email Address")
        setTextFields (textfieldName: tfPassword, view: vCredentials, yCoordinate: 310, placeholder: "Password")
        setTextFields (textfieldName: tfAddressLineOne, view: vCredentials, yCoordinate: 360, placeholder: "Address Line 1")
        setTextFields (textfieldName: tfAddressLineTwo, view: vCredentials, yCoordinate: 410, placeholder: "Address Line 2")
        setTextFields (textfieldName: tfAddressPostcode, view: vCredentials, yCoordinate: 460, placeholder: "Postcode")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(AlternativeSignUpViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AlternativeSignUpViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    //CREDENTIALS
    @IBAction func btnCancelFormClicked(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func btnMoveToPersonalDetailsClicked(_ sender: Any) {
        vCredentials.isHidden = true
        vPersonalDetails.isHidden = false
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
    
    
    
    //PERSONAL DETAILS
    @IBAction func btnBackToCredentialsClicked(_ sender: Any) {
        vPersonalDetails.isHidden = true
        vCredentials.isHidden = false
    }
    
    
    @IBAction func btnMoveToTeamDetailsClicked(_ sender: Any) {
        vPersonalDetails.isHidden = true
        vTeamDetails.isHidden = false
    }
    
    
    
    
    
    //TEAM DETAILS
    @IBAction func btnBackToPersonalDetailsClicked(_ sender: Any) {
        vTeamDetails.isHidden = true
        vPersonalDetails.isHidden = false
    }
    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        print("Submit Clicked")
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

    //enter button will close the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
    
    
}
