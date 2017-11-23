//
//  PlayersTableViewController.swift
//  TBG
//
//  Created by Kris Reid on 23/11/2017.
//  Copyright © 2017 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PlayersTableViewController: UITableViewController {
    
    var Oldplayers : [String] = []
    var players : [DataSnapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getManagersTeamId ()
        
    }
    
    @IBAction func btnTest(_ sender: Any) {
        print(players)
    }
    
//    @IBAction func logoutTapped(_ sender: Any) {
//        try? Auth.auth().signOut()
//        navigationController?.dismiss(animated: true, completion: nil)
//    }
    
    
    func getManagersTeamId () {
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Players").removeAllObservers()
                
                
                if let ManagerDictionary = snapshot.value as? [String:Any] {
                    if let teamID = ManagerDictionary["Team ID"] as? String {
                        // This will return the Logged In Managers Team ID
                        print(teamID)
                        self.tableView.reloadData()
                        
                        Database.database().reference().child("Players").queryOrdered(byChild: "Team ID").queryEqual(toValue: teamID).observe(.childAdded, with: { (snapshot) in
                            Database.database().reference().child("Players").removeAllObservers()
                            
                            if let PlayerDictionary = snapshot.value as? [String:Any] {
                                if let playerName = PlayerDictionary["Full Name"] as? String {
                                    self.Oldplayers.append(playerName)
                                    self.tableView.reloadData()
                                }
                            }
                        })
                    }
                }
            })
        }
    }
    


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Oldplayers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = Oldplayers[indexPath.row]

        return cell
    }
    


}
