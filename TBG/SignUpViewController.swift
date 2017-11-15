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

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfEmailAddress: UITextField!
    @IBOutlet weak var tfFullName: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var isManager = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func scTapped(_ sender: Any) {
        if (segmentedControl.selectedSegmentIndex == 0) {
            isManager = false
            //set management hidden = false
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            isManager = true
            //set managment fields to hidden = true
        }
    }
    
    @IBAction func btnSignup(_ sender: Any) {
        if tfFullName.text == "" || tfPassword.text == "" || tfEmailAddress.text == "" {
            displayAlert(title: "Missing Information", message: "You must provide both an email and password")
        } else {
            if let email = tfEmailAddress.text {
                if let password = tfPassword.text {
                    if let fullName = tfFullName.text {
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
                        let playerDictionary : [String:Any] = ["email": email, "fullName": fullName]
                    Database.database().reference().child("Players").childByAutoId().setValue(playerDictionary)
                        
                        self.performSegue(withIdentifier: "signupSubmitSegue", sender: nil)
                    
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


}
