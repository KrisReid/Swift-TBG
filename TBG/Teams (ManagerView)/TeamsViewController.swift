//
//  TeamsViewController.swift
//  TBG
//
//  Created by Kris Reid on 11/02/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MessageUI

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {
    
    let dataStore = DataStore.init()
    
    @IBOutlet weak var tvPlayers: UITableView!
    @IBOutlet weak var vShare: UIView!
    @IBOutlet weak var vShareCover: UIView!
    @IBOutlet weak var vSwipeDown: UIView!
    @IBOutlet weak var cvShare: UIView!
    
    var allPlayers : [DataSnapshot] = []
    var refresher: UIRefreshControl = UIRefreshControl()
    
    var teamId : String = ""
    var teamPIN: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = TokenGenerationViewController().viewDidLoad()

        //Refresh
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action:
            #selector(TeamsViewController.updatePlayers), for: UIControl.Event.valueChanged)
        tvPlayers.addSubview(refresher)
        
        //Styling
        styling()
        
        //Downswipe (Add Fixture)
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        downSwipe.direction = .down
        vShareCover.addGestureRecognizer(downSwipe)
        
        //Keyboard show and dismiss observers
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getPlayers ()
    }
    
    func styling () {
        vShare.layer.cornerRadius = CGFloat(10)
        vShare.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
        
        cvShare.frame = CGRect(x: 0 , y: 10, width: vShare.bounds.width, height: vShare.bounds.height)
        
        vShareCover.frame = CGRect(x: 0 , y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        vShareCover.alpha = 0
        
        vSwipeDown.layer.cornerRadius = CGFloat(5)
        vSwipeDown.frame = CGRect(x: UIScreen.main.bounds.width / 2 - vSwipeDown.frame.width / 2, y: UIScreen.main.bounds.height - 20, width: 48, height: 8)
        vSwipeDown.alpha = 0
    }
    
    
    @IBAction func btnShare(_ sender: Any) {
        UIView.animate(withDuration: 0.6) {
            self.vShare.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height - self.vShare.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
            self.vSwipeDown.frame = CGRect(x: UIScreen.main.bounds.width / 2 - self.vSwipeDown.frame.width / 2, y: UIScreen.main.bounds.height - self.vShare.bounds.height - 20, width: 48, height: 8)
            self.vShare.alpha = 1
            self.vShareCover.alpha = 1
            self.vSwipeDown.alpha = 1
        }
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .down) {
            print("Swipe Down")
            UIView.animate(withDuration: 0.6) {
                self.vShare.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
                self.vSwipeDown.frame = CGRect(x: UIScreen.main.bounds.width / 2 - self.vSwipeDown.frame.width / 2, y: UIScreen.main.bounds.height - 20, width: 48, height: 8)
                self.vShare.alpha = 0
                self.vShareCover.alpha = 0
                self.vSwipeDown.alpha = 0
            }
        }
    }
    
    
    @IBAction func btnLogOut(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    func setTextFields (textfieldName : UITextField) {
        let myColor = UIColor.gray
        textfieldName.layer.borderColor = myColor.cgColor
        textfieldName.layer.borderWidth = 1.0
        textfieldName.layer.cornerRadius = 10.0
    }
    
    
    @objc func updatePlayers () {
        
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Players").removeAllObservers()
                
                if let ManagerDictionary = snapshot.value as? [String:Any] {
                    if let teamID = ManagerDictionary["Team ID"] as? String {
                        
                        Database.database().reference().child("Players").queryOrdered(byChild: "Team ID").queryEqual(toValue: teamID).observe(.childAdded, with: { (snapshot) in
                            Database.database().reference().child("Players").removeAllObservers()
                            
                            let count = self.allPlayers.count
                            print("All Players count: \(self.allPlayers.count)")
                            var counting = 0
                            
                            if let key = snapshot.key as? String {
                                // 3 lines of new code for Trial
                                if count == 0 {
                                    self.allPlayers.append(snapshot)
                                }
                                for player in self.allPlayers {
                                    print("11111111")
                                    print(player.key)
                                    print(key)
                                    if player.key == key {
                                        print("It was found at least once")
                                    } else {
                                        counting += 1
                                        if counting == count {
                                            print("It never existed and therefore needs adding")
                                            self.allPlayers.append(snapshot)
                                        } else {
                                            print("//////")
                                            print(counting)
                                        }
                                    }
                                }
                            }
                            
                            self.tvPlayers.reloadData()
                            self.refresher.endRefreshing()
                        })
                    }
                }
            })
        }
        
        
    }
    
    @objc func getPlayers () {
        allPlayers = []
        
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Players").removeAllObservers()
                
                if let ManagerDictionary = snapshot.value as? [String:Any] {
                    if let teamID = ManagerDictionary["Team ID"] as? String {
//                        self.lblTeamId.text = teamID
                        self.teamId = teamID
                        
                        Database.database().reference().child("Players").queryOrdered(byChild: "Team ID").queryEqual(toValue: teamID).observe(.childAdded, with: { (snapshot) in
                            Database.database().reference().child("Players").removeAllObservers()
                            
                            self.allPlayers.append(snapshot)
                            self.tvPlayers.reloadData()
                            // self.tableView.reloadData()
                            self.refresher.endRefreshing()
                        })
                    }
                }
            })
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPlayers.count
//        return tableView == tvPlayers ? allPlayers.count : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if tableView == tvPlayers {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PlayersTableViewCell {
                let snapshot = allPlayers[indexPath.row]
                if let PlayerDictionary = snapshot.value as? [String:Any] {
                    if let fullName = PlayerDictionary["Full Name"] as? String, let imageURL = PlayerDictionary["ProfileImage"] as? String, let position = PlayerDictionary["Position"] as? String, let side = PlayerDictionary["Position Side"] as? String {
                        
                        cell.lblFullName.text = fullName
                        cell.lblPosition.text = position
                        cell.lblSide.text = side
                        
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
//        } else {
//            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as? ShareTableViewCell {
//                return cell
//            }
//        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= vShare.frame.height - 100
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += vShare.frame.height - 100
            }
        }
    }
    
    //closes the keyboard when you touch white space
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //enter button will close the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    


}
