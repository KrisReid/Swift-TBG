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
    
    var allPlayers : [DataSnapshot] = []
    
    var email = ""
    var name = ""
    var imageURL = ""
    
    var refresher: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(PlayersTableViewController.getTeam), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Look for better way of reloading the data
        getTeam ()
    }
    
    
    @IBAction func btnLogOut(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func getTeam () {
        allPlayers = []
        
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

                            self.allPlayers.append(snapshot)
                            self.tableView.reloadData()
                            self.refresher.endRefreshing()
                        })
                    }
                }
            })
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPlayers.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PlayersTableViewCell {

            let snapshot = allPlayers[indexPath.row]

            if let PlayerDictionary = snapshot.value as? [String:Any] {
                
                if let fullName = PlayerDictionary["Full Name"] as? String {
                    if let imageURL = PlayerDictionary["ProfileImage"] as? String {
                        
                        cell.lblFullName.text = fullName

                        let url = URL(string: imageURL)
                        let request = NSMutableURLRequest(url: url!)

                        let task = URLSession.shared.dataTask(with: request as URLRequest) {
                            data, response, error in

                            if error != nil {
                                print(error ?? "Error")
                            } else {
                                if let data = data {
                                    DispatchQueue.main.async {
                                        if let image = UIImage(data: data) {
                                            cell.ivProfilePic.image = image
                                        }
                                    }
                                }
                            }
                        }
                        task.resume()
                        return cell
                    }
                }
            }
        }
        return UITableViewCell()
    }
    
    //CODE FOR DELETING PLAYERS FROM THE DATABASE AND REFESHING
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let snapshot = allPlayers[indexPath.row]
            
            if let PlayerDictionary = snapshot.value as? [String:Any] {
                if let playerEmail = PlayerDictionary["Email"] as? String {
                    
                    Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: playerEmail).observe(.childAdded) { (snapshot) in
                        snapshot.ref.updateChildValues(["Team ID": ""])
                        Database.database().reference().child("Players").removeAllObservers()
                    }
                    
                    //reloading of the table
                    getTeam ()
                    
                }
                
            }
        

        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = allPlayers[indexPath.row]
        performSegue(withIdentifier: "playerDetailSegue", sender: snapshot)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? PlayerDetailViewController {
            
            if let snapshot = sender as? DataSnapshot {
                if let playerDictionary = snapshot.value as? [String:Any] {
                    if let email = playerDictionary["Email"] as? String {
                        if let name = playerDictionary["Full Name"] as? String {
                            if let image = playerDictionary["ProfileImage"] as? String {
                                if let position = playerDictionary["Position"] as? String {
                                    if let positionSide = playerDictionary["Position Side"] as? String {
                                        acceptVC.playerEmail = email
                                        acceptVC.playerName = name
                                        acceptVC.newImage = image
                                        acceptVC.position = position
                                        acceptVC.positionSide = positionSide
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
