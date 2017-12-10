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
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    var signupMode = false
    var playerEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(playerEmail)
        
        if playerEmail != "" {
            tfEmail.text = playerEmail
        }
        
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        if let email = tfEmail.text {
            if let password = tfPassword.text {
                
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error != nil {
                        self.displayAlert(title: "Error", message: error!.localizedDescription)
                    } else {
                        print("Logging in was successful")
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
