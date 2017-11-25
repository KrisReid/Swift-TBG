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
    
    var rowNumber = 0
    var players : [String] = []
    var images: [String?] = []
    // var profilePic: UIImage
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getTeam ()
    }
    
    
    @IBAction func btnLogOut(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    func getTeam () {
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
                                //print(PlayerDictionary)
                                if let playerName = PlayerDictionary["Full Name"] as? String {
                                    if let image = PlayerDictionary["ProfileImage"] as? String {
                                        self.players.append(playerName)
                                        self.images.append(image)
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        })
                    }
                }
            })
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PlayersTableViewCell {
            
            cell.lblFullName.text = players[indexPath.row]
    
            let url = URL(string: images[indexPath.row]!)
            let request = NSMutableURLRequest(url: url!)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print(error ?? "Error")
                } else {
                    if let data = data {
                        DispatchQueue.main.async {
                            if let image = UIImage(data: data) {
                                //self.profilePic = image
                                cell.ivProfilePic.image = image
                            }
                        }
                    }
                }
            }
            task.resume()
            return cell
            
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.rowNumber = indexPath.row
        let snapshot = players[indexPath.row]
        performSegue(withIdentifier: "playerDetailSegue", sender: snapshot)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? PlayerDetailViewController {
            
            acceptVC.playerName = players[rowNumber]
            // acceptVC.playerProfilePic = profilePic
            
        }
    }

}
