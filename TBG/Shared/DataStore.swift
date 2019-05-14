//
//  DataStore.swift
//  TBG
//
//  Created by Kris Reid on 21/02/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class DataStore {
    
    var teamFixtures : [DataSnapshot] = []
    var loggedInUser : [DataSnapshot] = []
    
    var userEmail: String = ""
    var managersPlayers : [DataSnapshot] = []
    
    
    func getCurrentUser() -> String {
        if let email = Auth.auth().currentUser?.email {
            self.userEmail = email
        }
        return self.userEmail
    }
    
    
    func getManagersPlayers () -> [DataSnapshot] {
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Players").removeAllObservers()
                
                if let ManagerDictionary = snapshot.value as? [String:Any] {
                    if let teamID = ManagerDictionary["Team ID"] as? String {
                        
                        Database.database().reference().child("Players").queryOrdered(byChild: "Team ID").queryEqual(toValue: teamID).observe(.childAdded, with: { (snapshot) in
                            Database.database().reference().child("Players").removeAllObservers()
                            
                            self.managersPlayers.append(snapshot)
                        })
                    }
                }
            })
        }
        return self.managersPlayers
    }
}
