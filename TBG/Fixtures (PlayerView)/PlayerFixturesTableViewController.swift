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
    var teamIdentity = ""
    var playerName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        getFixtures()
    }
    
    @objc func getFixtures () {
        
        self.teamFixtures = []
        
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                
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
                            // self.refresher.endRefreshing()
                            
                        })
                    }
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
                    
                    if let availablePlayers = TeamDictionary["Available Players"] as? [String:Any] {
                        if let player = availablePlayers[self.playerName] as? String {
                            cell.ivPlayingStatus.image = #imageLiteral(resourceName: "Accept.png")
                        }
                    }
                    if let unavailablePlayers = TeamDictionary["Unavailable Players"] as? [String:Any] {
                        if let player = unavailablePlayers[self.playerName] as? String {
                            cell.ivPlayingStatus.image = #imageLiteral(resourceName: "Reject.png")
                        }
                    }
                    if let maybePlayers = TeamDictionary["Maybe Players"] as? [String:Any] {
                        if let player = maybePlayers[self.playerName] as? String {
                            cell.ivPlayingStatus.image = #imageLiteral(resourceName: "maybe.png")
                        }
                    }
                    
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
            print("Accept button tapped")
            // Add function here
        }
        accept.backgroundColor = UIColor(red: 54/255, green: 217/255, blue: 122/255, alpha: 1.0)
        
        let maybe = UITableViewRowAction(style: .normal, title: "Maybe") { action, index in
            print("Maybe button tapped")
            // Add function here
        }
        maybe.backgroundColor = UIColor(red: 219/255, green: 135/255, blue: 66/255, alpha: 1.0)
        
        let reject = UITableViewRowAction(style: .normal, title: "Reject") { action, index in
            print("Reject button tapped")
            // Add function here
        }
        reject.backgroundColor = UIColor(red: 145/255, green: 20/255, blue: 20/255, alpha: 1.0)
        
        return [reject, maybe, accept]
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }





}
