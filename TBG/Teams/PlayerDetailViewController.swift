//
//  PlayerDetailViewController.swift
//  TBG
//
//  Created by Kris Reid on 25/11/2017.
//  Copyright © 2017 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PlayerDetailViewController: UIViewController {
    
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var ivPlayerProfilePicture: UIImageView!
    @IBOutlet weak var slrPlayerPosition: UISlider!
    @IBOutlet weak var slrPlayerPositionSide: UISlider!
    @IBOutlet weak var lblGK: UILabel!
    @IBOutlet weak var lblDEF: UILabel!
    @IBOutlet weak var lblMID: UILabel!
    @IBOutlet weak var lblSTR: UILabel!
    @IBOutlet weak var lblLeft: UILabel!
    @IBOutlet weak var lblCentre: UILabel!
    @IBOutlet weak var lblRight: UILabel!
    @IBOutlet weak var btnUpdate: UIButton!
    
    var playerEmail:String = ""
    var playerName: String = ""
    var newImage: String = ""
    var position: String = ""
    var positionSide: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPlayerName.text = playerName
        
        // GET THE IMAGE FROM THE PASSED URL
        let url = URL(string: newImage)
        let request = NSMutableURLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print(error ?? "Error")
            } else {
                if let data = data {
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data) {
                            self.ivPlayerProfilePicture.image = image
                        }
                    }
                }
            }
        }
        task.resume()
        
        ivPlayerProfilePicture.layer.cornerRadius = ivPlayerProfilePicture.frame.size.width / 2
        ivPlayerProfilePicture.layer.masksToBounds = true
        
        // SET THE SLIDERS TO THE CORRECT POSITION (POSITION SIDE)
        if positionSide == "Left" {
            slrPlayerPositionSide.value = 0
            leftActive()
        } else if positionSide == "Centre" {
            slrPlayerPositionSide.value = 1
            centreActive()
        } else {
            slrPlayerPositionSide.value = 2
            rightActive ()
        }
        
        // SET THE SLIDERS TO THE CORRECT POSITION (POSITION)
        if position == "Goalkepper" {
            slrPlayerPosition.value = 0
            gkActive()
        } else if position == "Defender" {
            slrPlayerPosition.value = 1
            defActive()
        } else if position == "Midfielder" {
            slrPlayerPosition.value = 2
            midActive()
        } else {
            slrPlayerPosition.value = 3
            strActive()
        }
        
    }
    
    func leftActive () {
        lblLeft.textColor = UIColor.black
        lblCentre.textColor = UIColor.gray
        lblRight.textColor = UIColor.gray
    }
    
    func centreActive () {
        lblLeft.textColor = UIColor.gray
        lblCentre.textColor = UIColor.black
        lblRight.textColor = UIColor.gray
    }
    
    func rightActive () {
        lblLeft.textColor = UIColor.gray
        lblCentre.textColor = UIColor.gray
        lblRight.textColor = UIColor.black
    }
    
    func gkActive () {
        lblGK.textColor = UIColor.black
        lblDEF.textColor = UIColor.gray
        lblMID.textColor = UIColor.gray
        lblSTR.textColor = UIColor.gray
    }
    
    func defActive () {
        lblGK.textColor = UIColor.gray
        lblDEF.textColor = UIColor.black
        lblMID.textColor = UIColor.gray
        lblSTR.textColor = UIColor.gray
    }
    
    func midActive () {
        lblGK.textColor = UIColor.gray
        lblDEF.textColor = UIColor.gray
        lblMID.textColor = UIColor.black
        lblSTR.textColor = UIColor.gray
    }
    
    func strActive () {
        lblGK.textColor = UIColor.gray
        lblDEF.textColor = UIColor.gray
        lblMID.textColor = UIColor.gray
        lblSTR.textColor = UIColor.black
    }
    
    
    @IBAction func slrPlayerPositionMoved(_ sender: Any) {
        if slrPlayerPosition.value >= 0 && slrPlayerPosition.value < 0.5 {
            //GK
            gkActive()
            btnUpdate.isHidden = false
            self.position = "Goal Keeper"
        } else if slrPlayerPosition.value >= 0.5 && slrPlayerPosition.value < 1.5  {
            //DEF
            defActive()
            btnUpdate.isHidden = false
            self.position = "Defender"
        } else if slrPlayerPosition.value >= 1.5 && slrPlayerPosition.value < 2.5 {
            // MID
            midActive()
            btnUpdate.isHidden = false
            self.position = "Midfielder"
        } else {
            //STR
            strActive()
            btnUpdate.isHidden = false
            self.position = "Striker"
        }
    }
    
    @IBAction func slrPlayerPositionSideMoved(_ sender: Any) {
        if slrPlayerPositionSide.value >= 0 && slrPlayerPositionSide.value < 0.5 {
            //LEFT
            leftActive()
            btnUpdate.isHidden = false
            self.positionSide = "Left"
        } else if slrPlayerPositionSide.value >= 0.5 && slrPlayerPositionSide.value < 1.5 {
            //CENTRE
            centreActive()
            btnUpdate.isHidden = false
            self.positionSide = "Centre"
        } else {
            //RIGHT
            rightActive()
            btnUpdate.isHidden = false
            self.positionSide = "Right"
        }
    }
    
    
    
    @IBAction func btnUpdateSelected(_ sender: Any) {
        //Update the Player Position
        Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: playerEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["Position":self.position, "Position Side":self.positionSide])
            Database.database().reference().child("Players").removeAllObservers()
        }
        
        // performSegue(withIdentifier: "updatePlayerPositionSegue", sender: nil)
        
        self.btnUpdate.isHidden = true
       
    }

    
}
