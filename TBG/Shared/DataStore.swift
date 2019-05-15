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
    
    var userEmail: String = ""
    var managersPlayers : [DataSnapshot] = []
    
    func getCurrentUser() -> String {
        if let email = Auth.auth().currentUser?.email {
            self.userEmail = email
        }
        return self.userEmail
    }
    
    
    func getManagersPlayers () -> [DataSnapshot] {
        print("111111111111")
        if let email = Auth.auth().currentUser?.email {
            print("2222222222222")
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Players").removeAllObservers()
                print("33333333333")
                if let ManagerDictionary = snapshot.value as? [String:Any] {
                    if let teamID = ManagerDictionary["Team ID"] as? String {
                        print("44444444444444444")
                        Database.database().reference().child("Players").queryOrdered(byChild: "Team ID").queryEqual(toValue: teamID).observe(.childAdded, with: { (snapshot) in
                            Database.database().reference().child("Players").removeAllObservers()
                            print("555555555555")
                            self.managersPlayers.append(snapshot)
                        })
                    }
                }
            })
        }
        return self.managersPlayers
    }
}
