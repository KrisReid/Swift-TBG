//
//  PlayerFixturesTableViewController.swift
//  TBG
//
//  Created by Kris Reid on 30/01/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PlayerFixturesTableViewController: UITableViewController {
    
    var teamFixtures : [DataSnapshot] = []
    var teamIdentity: String = ""
    var playerName = ""
    var playerId = ""
    
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
                
                self.playerId = snapshot.key
                
                if let PlayerDictionary = snapshot.value as? [String:Any] {
                    if let name = PlayerDictionary["Full Name"] as? String  {
                        self.playerName = name
                    }
                }
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamFixtures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PlayerFixturesTableViewCell {
            
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
                    
                    if let players = TeamDictionary["Players"] as? [String:Any] {
                        for player in players {
                            if player.key == playerId {
                                let value = player.value as? String
                                if value == "Available" {
                                    cell.ivPlayingStatus.image = #imageLiteral(resourceName: "Accept.png")
                                } else if value == "Unavailable" {
                                    cell.ivPlayingStatus.image = #imageLiteral(resourceName: "Reject.png")
                                } else {
                                    cell.ivPlayingStatus.image = #imageLiteral(resourceName: "maybe.png")
                                }
                            }
                        }
                    }
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    func SetPlayerToFixture(fixtureId: String, player: [String:String]) {
        Database.database().reference().child("Teams").child(self.teamIdentity).child("Fixtures").child(fixtureId).child("Players").updateChildValues(player)
    }
    
    
    func updatePlayerAvailability(fixtureId: String, availability: String, playerFixtureCount: Int) {
        
        var count = 0
        var skip = false
        Database.database().reference().child("Teams").child(self.teamIdentity).child("Fixtures").child(fixtureId).child("Players").observe(.childAdded) { (snapshot) in
            
            let player : [String:String] = [self.playerId: availability]
            
            if snapshot.key != self.playerId {
                count += 1
                if playerFixtureCount == count {
                    self.SetPlayerToFixture(fixtureId: fixtureId, player: player)
                    skip = true
                }
            } else {
                if skip {
                    print("WE Stop HERE")
                } else {
                    self.SetPlayerToFixture(fixtureId: fixtureId, player: player)
                }
            }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) is PlayerFixturesTableViewCell {
            
            let snapshot = self.teamFixtures[indexPath.row]
            
            var playerFixtureCount = 0
            
            if let TeamDictionary = snapshot.value as? [String:Any] {
                if let player = TeamDictionary["Players"] as? [String:Any] {
                    playerFixtureCount = player.count
                }
            }
            
            let fixtureId = snapshot.key
            
            let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
                print("Accept button tapped")
                print("\(fixtureId) and \(playerFixtureCount)")
                self.updatePlayerAvailability(fixtureId: fixtureId, availability: "Available", playerFixtureCount: playerFixtureCount)
                
                self.getFixtures()

            }
            accept.backgroundColor = UIColor(red: 54/255, green: 217/255, blue: 122/255, alpha: 1.0)
            
            let maybe = UITableViewRowAction(style: .normal, title: "Maybe") { action, index in
                print("Maybe button tapped")
                print("\(fixtureId) and \(playerFixtureCount)")
                self.updatePlayerAvailability(fixtureId: fixtureId, availability: "Maybe", playerFixtureCount: playerFixtureCount)
                
                self.getFixtures()
                
            }
            maybe.backgroundColor = UIColor(red: 219/255, green: 135/255, blue: 66/255, alpha: 1.0)
            
            let reject = UITableViewRowAction(style: .normal, title: "Reject") { action, index in
                print("Reject button tapped")
                print("\(fixtureId) and \(playerFixtureCount)")
                self.updatePlayerAvailability(fixtureId: fixtureId, availability: "Unavailable", playerFixtureCount: playerFixtureCount)
                
                self.getFixtures()
                
            }
            reject.backgroundColor = UIColor(red: 145/255, green: 20/255, blue: 20/255, alpha: 1.0)
            
            return [reject, maybe, accept]
        }
        return [UITableViewRowAction]()
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

}
