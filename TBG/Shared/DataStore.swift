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
    
    func getCurrentUser() -> String {
        if let email = Auth.auth().currentUser?.email {
            self.userEmail = email
        }
        return self.userEmail
    }
}
