//
//  TokenGenerationViewController.swift
//  TBG
//
//  Created by Kris Reid on 23/01/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class TokenGenerationViewController: UIViewController {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var email = ""
    var key = ""
    var teamId = ""
    var pushToken = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pushToken = self.delegate.token
        getEmail(completionBlock: getEmailHandlerBlock)
        
    }
    
    let getEmailHandlerBlock: (Bool) -> () = { (isSuccess: Bool) in
        if isSuccess {
            print("Get Email Function is completed")
        }
    }
    
    func getEmail(completionBlock: (Bool) -> Void) {
        if let email = Auth.auth().currentUser?.email {
            self.email = email
        }
        
        completionBlock(true)
        setPlayerToken()
    }
    

    func setPlayerToken() {
        Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: self.email).observe(.childAdded) { (snapshot) in
            
            self.key = snapshot.key
            print(self.key)
            
            if let Playerdictionary = snapshot.value as? [String:Any] {
                if let currentToken = Playerdictionary["Active Token"] as? String {
                    if let teamId = Playerdictionary["Team ID"] as? String {
                        
                        self.teamId = teamId
                        
                        // Update the Players token if applicable
                        if self.pushToken == currentToken {
                            print("Token was not updated in the DB as it matches")
                        } else {
                            // Update the new token to replace the old for the Player
                            snapshot.ref.updateChildValues(["Active Token":self.pushToken])
                            Database.database().reference().child("Players").removeAllObservers()
                        }
                    }
                }
            }
        }
    }

}
