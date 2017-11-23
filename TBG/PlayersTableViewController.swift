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
    
    var players : [String] = []
    var images: [String?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getTeam ()
    }
    
//    @IBAction func logoutTapped(_ sender: Any) {
//        try? Auth.auth().signOut()
//        navigationController?.dismiss(animated: true, completion: nil)
//    }
    
    
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
    


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
                    print(error)
                } else {
                    if let data = data {
                        if let image = UIImage(data: data) {
                            
                            cell.ivProfilePic.image = image
                            
//                            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//
//                            if documentsPath.count > 0 {
//                                let documentsDirectory = documentsPath[0]
//
//                                let savePath = documentsDirectory + "A.jpg"
//
//                                do {
//                                    try UIImageJPEGRepresentation(minionImage, 1)?.write(to: URL(fileURLWithPath: savePath))
//                                } catch {
//                                    print("Error")
//                                }
//                            }
                        }
                    }
                }
            }
            task.resume()
            return cell
            
        }
        return UITableViewCell()
    }



}
