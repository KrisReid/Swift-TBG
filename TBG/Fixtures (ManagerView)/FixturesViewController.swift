//
//  FixtureViewController.swift
//  TBG
//
//  Created by Kris Reid on 23/04/2019.
//  Copyright © 2019 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FixturesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet var tvFixtures: UITableView!
    @IBOutlet weak var vAddFixtureCover: UIView!
    @IBOutlet weak var vAddFixture: UIView!
    @IBOutlet weak var vSwipeDown: UIView!
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var vDatePicker: UIView!
    @IBOutlet weak var swHomeAway: UISwitch!
    @IBOutlet weak var ivHome: UIImageView!
    @IBOutlet weak var ivAway: UIImageView!
    @IBOutlet weak var tfOpposition: UITextField!
    @IBOutlet weak var tfVenue: UITextField!
    @IBOutlet weak var btnCreateGame: UIButton!
    
    let dataStore = DataStore.init()
    var teamFixtures : [DataSnapshot] = []
    var teamIdentity = ""
    var refresher: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Refresh
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action:
            #selector(FixturesViewController.updateFixtures), for: UIControl.Event.valueChanged)
        tvFixtures.addSubview(refresher)
        
        //Styling
        styling()
        
        //Downswipe (Add Fixture)
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        downSwipe.direction = .down
        vAddFixtureCover.addGestureRecognizer(downSwipe)
        
        //Keyboard show and dismiss observers
        NotificationCenter.default.addObserver(self, selector: #selector(FixturesViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FixturesViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Hide the keyboard
        tfDate.inputView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getFixtures ()
    }
    
    func styling () {
        vAddFixture.layer.cornerRadius = CGFloat(10)
        vAddFixture.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
        
        vAddFixtureCover.frame = CGRect(x: 0 , y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        vAddFixtureCover.alpha = 0
        
        vSwipeDown.layer.cornerRadius = CGFloat(5)
        vSwipeDown.frame = CGRect(x: UIScreen.main.bounds.width / 2 - vSwipeDown.frame.width / 2, y: UIScreen.main.bounds.height - 20, width: 48, height: 8)
        vSwipeDown.alpha = 0
        
        
        vDatePicker.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height - 300, width: UIScreen.main.bounds.width, height: 230)
        datePicker.frame = CGRect(x: 0 , y: 0, width: UIScreen.main.bounds.width, height: 230)
        
        setTextFields (textfieldName: tfDate, view: vAddFixture, yCoordinate: 30, placeholder: "Date / Time")
        
        swHomeAway.frame = CGRect(x: (vAddFixture.bounds.width - swHomeAway.bounds.width) / 2, y: 60, width: 49, height: 31)
        
        ivAway.frame = CGRect(x: (vAddFixture.bounds.width / 2) + 50, y: 60, width: 31, height: 31)
        
        ivHome.frame = CGRect(x: (vAddFixture.bounds.width / 2) - 31 - 50, y: 60, width: 31, height: 31)
        
        setTextFields (textfieldName: tfOpposition, view: vAddFixture, yCoordinate: 120, placeholder: "Opposition")
        setTextFields (textfieldName: tfVenue, view: vAddFixture, yCoordinate: 160, placeholder: "Venue")
        
        btnCreateGame.frame = CGRect(x: (vAddFixture.bounds.width - btnCreateGame.bounds.width) / 2, y: 190, width: 90, height: 30)
        
    }
    
    func setTextFields (textfieldName: UITextField, view: UIView, yCoordinate: CGFloat, placeholder: String) {
        let myColor = UIColor.gray
        textfieldName.layer.borderColor = myColor.cgColor
        textfieldName.layer.borderWidth = 1.0
        textfieldName.layer.cornerRadius = 10.0
        textfieldName.frame = CGRect(x: 0 , y: yCoordinate, width: view.frame.width / 1.2, height: 30)
        textfieldName.center = CGPoint(x: view.frame.width / 2, y: yCoordinate)
        textfieldName.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    @objc func updateFixtures () {
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Players").removeAllObservers()
                
                if let ManagerDictionary = snapshot.value as? [String:Any] {
                    if let teamID = ManagerDictionary["Team ID"] as? String {
                        self.teamIdentity = teamID
                        Database.database().reference().child("Teams/\(teamID)/Fixtures").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
                            
                            
                            let count = self.teamFixtures.count
                            print("All Fixtures count: \(self.teamFixtures.count)")
                            var counting = 0
                            
                            if let key = snapshot.key as? String {
                                if count == 0 {
                                    self.teamFixtures.append(snapshot)
                                }
                                for player in self.teamFixtures {
                                    if player.key == key {
                                        print("Fixture already exists")
                                    } else {
                                        counting += 1
                                        if counting == count {
                                            print("Add that Fixture: \(snapshot.key)")
                                            self.teamFixtures.append(snapshot)
                                        } else {
                                            print(counting)
                                        }
                                    }
                                }
                            }
                            self.tvFixtures.reloadData()
                            self.refresher.endRefreshing()
                            
                        })
                    }
                }
            })
        }
    }
    
    @objc func getFixtures () {
        teamFixtures = []
        
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Players").removeAllObservers()
                
                if let ManagerDictionary = snapshot.value as? [String:Any] {
                    if let teamID = ManagerDictionary["Team ID"] as? String {
                        self.teamIdentity = teamID
                        // This will return the Logged In Managers Team ID
                        Database.database().reference().child("Teams/\(teamID)/Fixtures").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
                            
                            self.teamFixtures.append(snapshot)
                            self.tvFixtures.reloadData()
                            self.refresher.endRefreshing()
                            
                        })
                    }
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamFixtures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? FixturesTableViewCellMore {
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = teamFixtures[indexPath.row]
        performSegue(withIdentifier: "FixtureDetailSegue", sender: snapshot)
    }
    
    //CODE FOR DELETING PLAYERS FROM THE DATABASE AND REFESHING
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    @IBAction func btnAddFixtureClicked(_ sender: Any) {
        UIView.animate(withDuration: 0.6) {
            self.vAddFixture.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height - self.vAddFixture.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
            self.vSwipeDown.frame = CGRect(x: UIScreen.main.bounds.width / 2 - self.vSwipeDown.frame.width / 2, y: UIScreen.main.bounds.height - self.vAddFixture.bounds.height - 20, width: 48, height: 8)
            self.vAddFixture.alpha = 1
            self.vAddFixtureCover.alpha = 1
            self.vSwipeDown.alpha = 1
        }
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .down) {
            print("Swipe Down")
            UIView.animate(withDuration: 0.6) {
                self.vAddFixture.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
                self.vSwipeDown.frame = CGRect(x: UIScreen.main.bounds.width / 2 - self.vSwipeDown.frame.width / 2, y: UIScreen.main.bounds.height - 20, width: 48, height: 8)
                self.vAddFixture.alpha = 0
                self.vAddFixtureCover.alpha = 0
                self.vSwipeDown.alpha = 0
            }
        }
    }
    
    @IBAction func tfDateStarted(_ sender: Any) {
        self.vDatePicker.isHidden = false
        
        UIView.animate(withDuration: 0.6) {
            
            self.vAddFixture.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height - self.vAddFixture.bounds.height - self.vDatePicker.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
            self.vSwipeDown.frame = CGRect(x: UIScreen.main.bounds.width / 2 - self.vSwipeDown.frame.width / 2, y: UIScreen.main.bounds.height - self.vAddFixture.bounds.height - self.vDatePicker.bounds.height - 20, width: 48, height: 8)
        }
        
    }
    
    func hidePicker () {
        self.vDatePicker.isHidden = true
        
        UIView.animate(withDuration: 0.6) {
            
            self.vAddFixture.frame = CGRect(x: 0 , y: UIScreen.main.bounds.height - self.vAddFixture.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
            self.vSwipeDown.frame = CGRect(x: UIScreen.main.bounds.width / 2 - self.vSwipeDown.frame.width / 2, y: UIScreen.main.bounds.height - self.vAddFixture.bounds.height - 20, width: 48, height: 8)
        }
    }
    
    @IBAction func tfDateFinished(_ sender: Any) {
        hidePicker()
    }
    
    @IBAction func datePickerAction(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let strDate = dateFormatter.string(from: datePicker.date)
        
        self.tfDate.text = String(strDate)
    }
    
    
    @IBAction func swHomeAwayClicked(_ sender: Any) {
        hidePicker()
    }
    
    
    @IBAction func btnCreateGameClicked(_ sender: Any) {
        
    }
    
    //Keyboard will Show
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= 240
            }
        }
    }
    
    //Keyboard will hide
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += 240
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

