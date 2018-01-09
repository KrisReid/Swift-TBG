//
//  FixturesTableViewController.swift
//  TBG
//
//  Created by Kris Reid on 01/01/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FixturesTableViewController: UITableViewController {
    
    var teamFixtures : [DataSnapshot] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFixtures()

    }
    
    @objc func getFixtures () {
        
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Players").removeAllObservers()
                
                if let ManagerDictionary = snapshot.value as? [String:Any] {
                    if let teamID = ManagerDictionary["Team ID"] as? String {
                        // This will return the Logged In Managers Team ID
                        
                        Database.database().reference().child("Teams/\(teamID)/Fixtures").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
                            
                            self.teamFixtures.append(snapshot)
                            self.tableView.reloadData()
                            
                        })
                    }
                }
            })
        }
    }

    
    @IBAction func btnAddFixture(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addFixtureSegue", sender: nil)
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamFixtures.count

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let snapshot = teamFixtures[indexPath.row]
        if let TeamDictionary = snapshot.value as? [String:Any] {
            if let venue = TeamDictionary["Venue"] as? String {
                cell.textLabel?.text = venue
                return cell
            }

        }
        
        return cell
        
    }

}
