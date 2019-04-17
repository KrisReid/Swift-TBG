//
//  LoginViewController.swift
//  TBG
//
//  Created by Kris Reid on 05/12/2017.
//  Copyright © 2017 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var imgBackgroundGIF: UIImageView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var newSignup: UIButton!
    @IBOutlet weak var vSignInContainer: UIView!
    
    //let dataStore = Person.init()
    
    var playerEmail = ""
    var playerPassword = ""
    
    var counter = 1
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 0.16, target: self, selector: #selector(LoginViewController.animate), userInfo: nil, repeats: true)
        
        if playerEmail != "" {
            tfEmail.text = playerEmail
        }
        
        //Set the containers
        setContainer(container: vSignInContainer, leftButton: newSignup, rightButton: loginButton);
        
        setTextFields(textfieldName: tfEmail, view: vSignInContainer, yCoordinate: vSignInContainer.frame.height / 3, placeholder: "Email Address")
        setTextFields(textfieldName: tfPassword, view: vSignInContainer, yCoordinate: vSignInContainer.frame.height / 2, placeholder: "Password")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //GENERAL FUNCTIONS
    func setContainer (container: UIView, leftButton: UIButton, rightButton:UIButton) {
        //SET THE CONTAINER
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.cgColor
        container.layer.cornerRadius = 10
        container.frame = CGRect(x: 0 , y: 0, width: UIScreen.main.bounds.height / 2.5, height: UIScreen.main.bounds.height / 3)
        container.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 1.3)
        
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
//                self.view.frame.origin.y -= keyboardSize.height
                self.view.frame.origin.y -= 300
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
//                self.view.frame.origin.y += keyboardSize.height
                self.view.frame.origin.y += 300
            }
        }
    }
    
    
    @objc func animate() {
        imgBackgroundGIF.image = UIImage(named: "frame_\(counter)_delay-0.16s.gif")
        
        counter += 1
        
        if counter == 81 {
            counter = 0
        }
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        if let email = tfEmail.text {
            if let password = tfPassword.text {
                
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error != nil {
                        self.displayAlert(title: "Error", message: error!.localizedDescription)
                    } else {
                        if user?.displayName == "Manager" {
                            //MANAGER
                            self.performSegue(withIdentifier: "ManagerSegue", sender: nil)
                        } else {
                            //PLAYER
                            self.performSegue(withIdentifier: "PlayerSegue", sender: nil)
                        }
                        
                    }
                })
                
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
