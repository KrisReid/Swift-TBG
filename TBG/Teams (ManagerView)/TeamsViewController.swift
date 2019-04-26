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

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, UITextFieldDelegate  {
    
    let dataStore = DataStore.init()
    
    @IBOutlet weak var tvPlayers: UITableView!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblTeamIdDescription: UILabel!
    @IBOutlet weak var lblTeamId: UILabel!
    @IBOutlet weak var lblTeamPINDescription: UILabel!
    @IBOutlet weak var lblTeamPIN: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnUpdatePIN: UIButton!
    @IBOutlet weak var tfPIN: UITextField!
    @IBOutlet weak var vShare: UIView!
    @IBOutlet weak var vShareCover: UIView!
    @IBOutlet weak var btnCloseShare: UIButton!
    
    
    var allPlayers : [DataSnapshot] = []
    var refresher: UIRefreshControl = UIRefreshControl()
    
    var teamId : String = ""
    var teamPIN: Int = 0
    var PINEditMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = TokenGenerationViewController().viewDidLoad()

        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action:
            #selector(TeamsViewController.updatePlayers), for: UIControl.Event.valueChanged)
        tvPlayers.addSubview(refresher)
        
        btnShare.layer.cornerRadius = 5.0
        setTextFields(textfieldName: tfPIN)
        
        vShare.layer.cornerRadius = CGFloat(10)
        
        vShare.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
        
        vShareCover.frame = CGRect(x: 0 , y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        vShareCover.alpha = 0
        
        btnCloseShare.frame = CGRect(x: vShare.bounds.width - btnCloseShare.bounds.width, y: 0, width: 30, height: 30)
        lblTeamName.frame = CGRect(x: 10, y: 0, width: vShare.bounds.width - btnCloseShare.bounds.width, height: 30)
        lblTeamIdDescription.frame = CGRect(x: 10, y: 60, width: 70, height: 30)
        lblTeamId.frame = CGRect(x: lblTeamIdDescription.frame.width + 20, y: 60, width: vShare.bounds.width - lblTeamIdDescription.frame.width + 20, height: 30)
        
        lblTeamPINDescription.frame = CGRect(x: 10, y: 90, width: 70, height: 30)
        lblTeamPIN.frame = CGRect(x: lblTeamPINDescription.frame.width + 20, y: 90, width: vShare.bounds.width - lblTeamPINDescription.frame.width - 80, height: 30)
        tfPIN.frame = CGRect(x: lblTeamPINDescription.frame.width + 20, y: 90, width: vShare.bounds.width - lblTeamPINDescription.frame.width - 80, height: 30)
        btnUpdatePIN.frame = CGRect(x: lblTeamPINDescription.frame.width + 20 + lblTeamPIN.frame.width + 20, y: 90, width: 21, height: 21)
        
        btnShare.frame = CGRect(x: vShare.frame.width / 2 - 50, y: 170, width: 100, height: 30)
        
        //Keyboard show and dismiss observers
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getPlayers ()
    }
    
    //SMS CODE
    @IBAction func btnShareClicked(_ sender: Any) {
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Hey, \n\nCome join my team at TNF using: \n\nTeam ID: \(teamId) \n\nTeam PIN: \(teamPIN) \n\nDownload on the app store here"
            //controller.recipients = [phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    //SMS CODE
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnShare(_ sender: Any) {
        print("Share Me Half Modal")
        
        UIView.animate(withDuration: 0.6) {
            self.vShare.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height - self.vShare.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
            self.vShare.alpha = 1
            self.vShareCover.alpha = 1
        }
        
    }
    
    @IBAction func btnCloseShareClicked(_ sender: Any) {
        UIView.animate(withDuration: 0.6) {
            self.vShare.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
            self.vShare.alpha = 0
            self.vShareCover.alpha = 0
        }
    }
    
    
    @IBAction func btnLogOut(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnUpdatePINClicked(_ sender: Any) {
        if PINEditMode {
            tfPIN.isHidden = false
            lblTeamPIN.isHidden = true
            btnUpdatePIN.setImage(#imageLiteral(resourceName: "upload.png"), for: .normal)
            self.PINEditMode = false
        } else {
//            if tfPIN.text?.characters.count == 6 {
            if tfPIN.text?.count == 6 {
                tfPIN.isHidden = true
                lblTeamPIN.isHidden = false
                lblTeamPIN.text = tfPIN.text
                
                btnUpdatePIN.setImage(#imageLiteral(resourceName: "edit.png"), for: .normal)
                self.PINEditMode = true
                
                Database.database().reference().child("Teams").queryOrdered(byChild: "id").queryEqual(toValue: teamId).observe(.childAdded, with: { (snapshot) in

                    print(Int(self.teamPIN))
                    snapshot.ref.updateChildValues(["PIN": Int(self.tfPIN.text!)!])
                    Database.database().reference().child("Teams").removeAllObservers()
                })
                
                self.view.endEditing(true)
            }
        }
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
                        self.lblTeamId.text = teamID
                        self.teamId = teamID
                        self.getTeam(teamId: teamID)
                        
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
    
    func getTeam (teamId:String) {
        Database.database().reference().child("Teams").queryOrdered(byChild: "id").queryEqual(toValue: teamId).observe(.childAdded, with: { (snapshot) in
            
            if let TeamDictionary = snapshot.value as? [String:Any] {
                if let teamName = TeamDictionary["Team Name"] as? String, let PIN = TeamDictionary["PIN"] as? Int {
                    
                    self.lblTeamName.text = teamName
                    self.lblTeamPIN.text = String(PIN)
                    self.teamPIN = PIN
                }
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPlayers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
