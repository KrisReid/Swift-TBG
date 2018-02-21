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
    
    // GET LOGGED IN USER
//    let currentUserHandlerBlock: (Bool) -> () = { (isSuccess: Bool) in
//        if isSuccess {
//            print("Function has completed")
//        }
//    }

//    func getCurrentUser(completionBlock: (Bool) -> Void) -> String {
//        if let email = Auth.auth().currentUser?.email {
//            self.userEmail = email
//        }
//        return self.userEmail
//        completionBlock(true)
//    }
    
    func getCurrentUser() -> String {
        if let email = Auth.auth().currentUser?.email {
            self.userEmail = email
        }
        return self.userEmail
    }
    

    
//    func getStadiums(complition: @escaping ([Stadium]) -> Void){
//        var stadiums: [Stadium] = []
//        let stadiumRef = Database.database().reference().child("Stadium")
//        stadiumRef.observe(.value, with: { (snapshot) in
//            stadiums.removeAll() // start with an empty array
//            for snap in snapshot.children {
//                guard let stadiumSnap = snap as? DataSnapshot else {
//                    print("Something wrong with Firebase DataSnapshot")
//                    complition(stadiums)
//                    return
//                }
//                let stadium = Stadium(snap: stadiumSnap)
//                stadiums.append(stadium)
//            }
//            complition(stadiums)
//        })
//    }
    
    
//    func getUserDetails () -> [DataSnapshot] {
//        for i in 100...200 {
//            print(i)
//        }
//        Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: userEmail).observe(.childAdded, with: { (snapshot) in
//            Database.database().reference().child("Players").removeAllObservers()
//
//            self.loggedInUser.append(snapshot)
//        })
//        return self.loggedInUser
//    }
    
    


    
}
