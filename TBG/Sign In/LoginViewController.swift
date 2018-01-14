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
    var playerPassword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(playerEmail)
        
        if playerEmail != "" {
            tfEmail.text = playerEmail
        }
        
        if let url = URL(string: "https://fcm.googleapis.com/fcm/send") {
            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = ["Content-Type":"application/json","Authorization":"key=AAAA7rglZew:APA91bEj2s8uNgjlptrh8ULTuJzD9d5lxTElN7Jln_LLUWnng-5AUHO6087KwqQ7YMOLu0UcXV0Y44_Hd09KLc6ZD-I_iupcjIMoz37vbbyG79ibrd83NFTtfCLUmzN2DBI6XYv_d0sO"]
            request.httpMethod = "POST"
            request.httpBody = "{\"to\":\"chmjS7GeGZc:APA91bGmOHwDj-aqMg7-RNjckv1zAWxAL8i0jGv-7IED5xZvc8ds_4i8Y73fDZUld5KwjD3kBkw4plblzdCQH7NEo8Cf8-XcL6vpgzTp-wt_rWCOxLpjBrU194ZLY0GBk-zLtPNxTYqr\",\"notification\":{\"title\":\"THIS IS FROM HTTP!\"}}".data(using: .utf8)
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, urlresponse, error) in
                if error != nil {
                    print(error!)
                } else {
                    
                }
            }).resume()
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
                        // print(user?.uid)
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
