//
//  ShareTableViewController.swift
//  TBG
//
//  Created by Kris Reid on 13/05/2019.
//  Copyright © 2019 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ShareTableViewController: UITableViewController  {
    
//    let dataStore = DataStore.init()
    
    @IBOutlet weak var lblTeamIdDescription: UILabel!
    @IBOutlet weak var lblTeamId: UILabel!
    @IBOutlet weak var lblTeamPINDescription: UILabel!
    @IBOutlet weak var lblTeamPIN: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblActive: UILabel!
    @IBOutlet weak var tvShare: UITableView!
    
    var teamId : String = ""
    var teamPIN: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPlayers ()
        
        lblTeamIdDescription.frame = CGRect(x: 20, y: 20, width: 70, height: 30)
        lblTeamPINDescription.frame = CGRect(x: 20, y: 20, width: 70, height: 30)
        lblTeamId.frame = CGRect(x: 100, y: 20, width: UIScreen.main.bounds.width - 120, height: 30)
        lblTeamPIN.frame = CGRect(x: 100, y: 20, width: UIScreen.main.bounds.width - 140, height: 30)
        lblActive.frame = CGRect(x: 100, y: 20, width: UIScreen.main.bounds.width - 120, height: 30)
//        btnShare.frame = CGRect(x: 10, y: 20, width: 100, height: 30)
        
        
//        let b = dataStore.getManagersPlayers()
//        print("My managers players folks: \(b)");
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
//    @IBAction func btnShareClicked(_ sender: Any) {
//        
//        if (messageComposeViewController.canSendText()) {
//            let controller = messageComposeViewController()
//            controller.body = "Hey, \n\nCome join my team at TNF using: \n\nTeam ID: \(teamId) \n\nTeam PIN: \(teamPIN) \n\nDownload on the app store here"
//            //controller.recipients = [phoneNumber]
//            controller.messageComposeDelegate = self
//            self.present(controller, animated: true, completion: nil)
//        }
//        
//    }
    
//    //SMS CODE
//    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
//        self.dismiss(animated: true, completion: nil)
//    }
    
    
    //    @IBAction func btnUpdatePINClicked(_ sender: Any) {
    //        if PINEditMode {
    //            tfPIN.isHidden = false
    //            lblTeamPIN.isHidden = true
    //            btnUpdatePIN.setImage(#imageLiteral(resourceName: "upload.png"), for: .normal)
    //            self.PINEditMode = false
    //        } else {
    ////            if tfPIN.text?.characters.count == 6 {
    //            if tfPIN.text?.count == 6 {
    //                tfPIN.isHidden = true
    //                lblTeamPIN.isHidden = false
    //                lblTeamPIN.text = tfPIN.text
    //
    //                btnUpdatePIN.setImage(#imageLiteral(resourceName: "edit.png"), for: .normal)
    //                self.PINEditMode = true
    //
    //                Database.database().reference().child("Teams").queryOrdered(byChild: "id").queryEqual(toValue: teamId).observe(.childAdded, with: { (snapshot) in
    //
    //                    print(Int(self.teamPIN))
    //                    snapshot.ref.updateChildValues(["PIN": Int(self.tfPIN.text!)!])
    //                    Database.database().reference().child("Teams").removeAllObservers()
    //                })
    //
    //                self.view.endEditing(true)
    //            }
    //        }
    //    }
    
    
    @objc func getPlayers () {
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Players").removeAllObservers()
                
                if let ManagerDictionary = snapshot.value as? [String:Any] {
                    if let teamID = ManagerDictionary["Team ID"] as? String {
                        self.lblTeamId.text = teamID
//                        self.teamId = teamID
                        self.getTeam(teamId: teamID)
                    }
                }
            })
        }
    }
    
    func getTeam (teamId:String) {
        Database.database().reference().child("Teams").queryOrdered(byChild: "id").queryEqual(toValue: teamId).observe(.childAdded, with: { (snapshot) in
            
            if let TeamDictionary = snapshot.value as? [String:Any] {
                if let teamName = TeamDictionary["Team Name"] as? String, let PIN = TeamDictionary["PIN"] as? Int {
                    self.lblTeamPIN.text = String(PIN)
//                    self.teamPIN = PIN
                }
            }
        })
    }
    
    
}
