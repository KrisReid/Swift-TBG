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
        
        setTextFields(textfieldName: tfEmail)
        setTextFields(textfieldName: tfPassword)
        
        loginButton.layer.cornerRadius = 5.0
        signupButton.layer.cornerRadius = 5.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setTextFields (textfieldName : UITextField) {
        let myColor = UIColor.white
        textfieldName.layer.borderColor = myColor.cgColor
        textfieldName.layer.borderWidth = 1.0
        textfieldName.layer.cornerRadius = 10.0
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
//                self.view.frame.origin.y -= keyboardSize.height
                self.view.frame.origin.y -= 40
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
//                self.view.frame.origin.y += keyboardSize.height
                self.view.frame.origin.y += 40
            }
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        timer = Timer.scheduledTimer(timeInterval: 0.16, target: self, selector: #selector(LoginViewController.animate), userInfo: nil, repeats: true)
//    }
    
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
