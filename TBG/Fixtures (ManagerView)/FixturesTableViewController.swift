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
    
    var teamIdentity = ""
     var refresher: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(FixturesTableViewController.getFixtures), for: UIControl.Event.valueChanged)
        tableView.addSubview(refresher)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        getFixtures()
    }
    
    @objc func getFixtures () {
        
        self.teamFixtures = []
        
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Players").removeAllObservers()
                
                if let ManagerDictionary = snapshot.value as? [String:Any] {
                    if let teamID = ManagerDictionary["Team ID"] as? String {
                        self.teamIdentity = teamID
                        // This will return the Logged In Managers Team ID
                        Database.database().reference().child("Teams/\(teamID)/Fixtures").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
                            
                            self.teamFixtures.append(snapshot)
                            self.tableView.reloadData()
                            self.refresher.endRefreshing()
                            
                        })
                    }
                }
            })
        }
    }

    
    @IBAction func btnAddFixture(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addFixtureSegue", sender: nil)
    }
    
    //CODE FOR DELETING PLAYERS FROM THE DATABASE AND REFESHING
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            let snapshot = teamFixtures[indexPath.row]
            print(snapshot)
            let key = snapshot.key
            
            Database.database().reference().child("Teams/\(self.teamIdentity)/Fixtures/\(key)").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
                snapshot.ref.removeValue()
                
            })
            self.getFixtures()
        }
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamFixtures.count

    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? FixturesTableViewCell {
            
            let snapshot = teamFixtures[indexPath.row]
            if let TeamDictionary = snapshot.value as? [String:Any] {
                if let venue = TeamDictionary["Venue"] as? String, let opposition = TeamDictionary["Away Team Name"] as? String, let dateTime = TeamDictionary["Date and Time"] as? String, let homeAway = TeamDictionary["Home or Away"] as? String {
                    
                        cell.lblOpposition.text = opposition
                        cell.lblDateTime.text = dateTime
                        cell.lblVenue.text = venue
                    
                        if homeAway == "Home" {
                            cell.ivHomeAway.image = #imageLiteral(resourceName: "Home.png")
                        } else {
                            cell.ivHomeAway.image = #imageLiteral(resourceName: "Away.png")
                        }
                    
                        return cell
                }
            }
        }
        return UITableViewCell()

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = teamFixtures[indexPath.row]
        performSegue(withIdentifier: "FixtureDetailSegue", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? FixtureDetailViewController {
            
            if let snapshot = sender as? DataSnapshot {
                if let FixtureDictionary = snapshot.value as? [String:Any] {
                    if let opposition = FixtureDictionary["Away Team Name"] as? String {
                        if let players = FixtureDictionary["Players"] as? [String:Any] {
                            
                            acceptVC.opposition = opposition
                            acceptVC.playerKeys = players
                            
                            let playerKeys = players.keys
                            for id in playerKeys {
                            Database.database().reference().child("Players").queryOrderedByKey().queryEqual(toValue: id ).observe(.childAdded) {(snapshot) in
                                
                                    if let PlayerDictionary = snapshot.value as? [String:Any] {
                                        if PlayerDictionary["Position"] as? String == "Striker" {
                                            acceptVC.strikers.append(snapshot)
                                        } else if PlayerDictionary["Position"] as? String == "Midfielder" {
                                            acceptVC.midfielders.append(snapshot)
                                        } else if PlayerDictionary["Position"] as? String == "Defender" {
                                            acceptVC.defenders.append(snapshot)
                                        } else {
                                            acceptVC.goalkeepers.append(snapshot)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }


}
