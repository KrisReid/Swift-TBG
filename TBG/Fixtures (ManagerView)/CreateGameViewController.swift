//
//  CreateGameViewController.swift
//  TBG
//
//  Created by Kris Reid on 26/12/2017.
//  Copyright © 2017 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateGameViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var btnOpposition: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var btnDateOpenClose: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var tfVenue: UITextField!
    @IBOutlet weak var tfOpposition: UITextField!
    
    var allPlayers = [Dictionary<String, Any>]()
    var playerKeys: [String] = []
//    var playerIdDictionary = [String:Any]()
    
    var dateMode = true
    var oppositionMode = true
    var homeTeamId = ""
    var homeTeamName = ""
    var homeOrAway = "Home"
    
    var managerName : String = ""
    var managerId : String = ""
    
    var tokens : [String] = []
    
    let teams = ["Avonmouth", "Shirehampton", "Welwyn"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTeamName()
        getPlayersTokens()
        
    }
    
    func getTeamName () {
        //Email of manager signed in
        let managerEmail = Auth.auth().currentUser?.email
        
        //Get the record of the manager signed in
        Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: managerEmail).observe(.childAdded) { (snapshot) in
            
            Database.database().reference().child("Players").removeAllObservers()
            
            if let managerDictionary = snapshot.value as? [String:Any] {
                if let teamID = managerDictionary["Team ID"] as? String  {
                    if let managerName = managerDictionary["Full Name"] as? String {
                        
                        self.managerName = managerName
                        self.managerId = snapshot.key
                        self.homeTeamId = teamID
                        
                        Database.database().reference().child("Teams").queryOrdered(byChild: "id").queryEqual(toValue: teamID).observe(.childAdded, with: { (snapshot) in
                            Database.database().reference().child("Teams").removeAllObservers()
                            
                            if let teamDictionary = snapshot.value as? [String:Any] {
                                if let teamName = teamDictionary["Team Name"] as? String {
                                    
                                    self.homeTeamName = teamName
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func getPlayersTokens () {
        //Email of manager signed in
        let managerEmail = Auth.auth().currentUser?.email
        
        //Get the record of the manager signed in
        Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: managerEmail).observe(.childAdded) { (snapshot) in
            
            Database.database().reference().child("Players").removeAllObservers()
            
            if let managerDictionary = snapshot.value as? [String:Any] {
                if let teamID = managerDictionary["Team ID"] as? String  {
                    Database.database().reference().child("Players").queryOrdered(byChild: "Team ID").queryEqual(toValue: teamID).observe(.childAdded, with: { (snapshot) in
                        
                        self.playerKeys.append(snapshot.key)
                        
                        Database.database().reference().child("Players").removeAllObservers()
                        if let playerDictionary = snapshot.value as? [String:Any] {
                            if let token = playerDictionary["Active Token"] as? String {
                                
                                self.tokens.append(token)
                            }
                        }
                    })
                    
                }
            }
        }
    }
    
    func pushNotifiy() {
        for token in tokens {
            if let url = URL(string: "https://fcm.googleapis.com/fcm/send") {
                var request = URLRequest(url: url)
                request.allHTTPHeaderFields = ["Content-Type":"application/json","Authorization":"key=AAAA7rglZew:APA91bEj2s8uNgjlptrh8ULTuJzD9d5lxTElN7Jln_LLUWnng-5AUHO6087KwqQ7YMOLu0UcXV0Y44_Hd09KLc6ZD-I_iupcjIMoz37vbbyG79ibrd83NFTtfCLUmzN2DBI6XYv_d0sO"]
                
                request.httpMethod = "POST"
                request.httpBody = "{\"to\":\"\(token)\",\"notification\":{\"title\":\"A new Game has been created. Can you play?\"}}".data(using: .utf8)
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data, urlresponse, error) in
                    if error != nil {
                        print(error!)
                    } else {
                        
                    }
                }).resume()
            }
        }
    }
    
    
    @IBAction func switchTapped(_ sender: Any) {
        if `switch`.isOn == true {
            self.homeOrAway = "Away"
        } else {
            self.homeOrAway = "Home"
        }
    }
    
    
    @IBAction func btnCreateGame(_ sender: Any) {
        
        if let date = tfDate.text {
            if let venue = tfVenue.text {
                if let opposition = tfOpposition.text {
                    if date == "" || venue == "" || opposition == "" {
                        self.displayAlert(title: "Missing Information", message: "You must provide information in all of the fields provided.")
                    } else {
                        
                        //Add the basic fixture structure
                        let fixtureDictionary : [String:Any] = ["Date and Time": date, "Home Team Name": self.homeTeamName, "Away Team Name": opposition, "Home or Away": self.homeOrAway, "Venue": venue]
                        let newFixture =  Database.database().reference().child("Teams").child(self.homeTeamId).child("Fixtures").childByAutoId()
                        newFixture.setValue(fixtureDictionary)
                        
                        //Capture the key
                        let newFixtureId = newFixture.key

                        //Manager added as available
                        let manager : [String:Any] = [self.managerId:"Available"]
                        let newPlayerFixture = Database.database().reference().child("Teams").child(self.homeTeamId).child("Fixtures").child(newFixtureId).child("Players")
                        newPlayerFixture.setValue(manager)
                        
                        //Send Push Notification
                        self.pushNotifiy()
                        
                        //notify success
                        self.displayAlert(title: "Game Created", message: "The game has been added to your teams fixture list")
                        
                        //reset the page to empty
                        tfDate.text = ""
                        tfVenue.text = ""
                        tfOpposition.text = ""
                        `switch`.isOn = false
                        
                    }
                }
            }
        }
    }
    
    @IBAction func btnDateTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.datePicker.isHidden = !self.datePicker.isHidden
            self.view.layoutIfNeeded()
        })
        
        if dateMode {
            dateMode = false
            btnDateOpenClose.setTitle("OK", for: .normal)
        } else {
            dateMode = true
            btnDateOpenClose.setTitle("Pick Date", for: .normal)
        }
    }
    
    @IBAction func btnOppositionClicked(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.pickerView.isHidden = !self.pickerView.isHidden
            self.view.layoutIfNeeded()
        })
        
        if oppositionMode {
            oppositionMode = false
            btnOpposition.setTitle("OK", for: .normal)
        } else {
            oppositionMode = true
            btnOpposition.setTitle("Pick Team", for: .normal)
        }
    }
    
    // Code for Date Picker
    @IBAction func datePickerAction(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let strDate = dateFormatter.string(from: datePicker.date)

        self.tfDate.text = String(strDate)
    }
    
    //code for Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teams.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teams[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tfOpposition.text = teams[row]
    }
    
    //Alert code
    func displayAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
