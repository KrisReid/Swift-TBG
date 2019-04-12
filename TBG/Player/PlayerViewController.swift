//
//  PlayerViewController.swift
//  TBG
//
//  Created by Kris Reid on 22/01/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var lblAddressLine1: UILabel!
    @IBOutlet weak var lblAddressLine2: UILabel!
    @IBOutlet weak var lblPostcode: UILabel!
    @IBOutlet weak var ivProfilePic: UIImageView!
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBOutlet weak var lblGK: UILabel!
    @IBOutlet weak var lblDEF: UILabel!
    @IBOutlet weak var lblMID: UILabel!
    @IBOutlet weak var lblSTR: UILabel!
    @IBOutlet weak var lblLEFT: UILabel!
    @IBOutlet weak var lblCENTRE: UILabel!
    @IBOutlet weak var lblRIGHT: UILabel!
    
    @IBOutlet weak var tfAddressLine1: UITextField!
    @IBOutlet weak var tfAddressLine2: UITextField!
    @IBOutlet weak var tfPostcode: UITextField!
    
    @IBOutlet weak var btnEditAddress: UIButton!
    @IBOutlet weak var btnEditPosition: UIButton!
    @IBOutlet weak var btnEditPositionSide: UIButton!
    @IBOutlet weak var btnLeaveJoin: UIButton!
    
    @IBOutlet weak var vLoading: UIView!
    
    @IBOutlet weak var slrPosition: UISlider!
    @IBOutlet weak var slrPositionSide: UISlider!
    
    var email: String = ""
    var imageURL: String = ""
    var address1: String = ""
    var address2: String = ""
    var postcode: String = ""
    var name: String = ""
    var position: String = ""
    var positionSide: String = ""
    var teamName: String = ""
    
    var editAddress1Mode = true
    var editEmailMode = true
    var editPositionMode = true
    var editPositionSideMode = true
    
    var haveClub = true
    let activityIndicator = UIActivityIndicatorView(frame:CGRect(x: 0, y: 0, width: 150, height: 150))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = TokenGenerationViewController().viewDidLoad()
        
        getPlayer(completionBlock: getPlayerHandlerBlock)
    }
    
    let getPlayerHandlerBlock: (Bool) -> () = { (isSuccess: Bool) in
        if isSuccess {
            print("Function is completed")
        }
    }
    
    func getPlayer(completionBlock: @escaping (Bool) -> Void) {
        startSpinner()
        if let email = Auth.auth().currentUser?.email {
            self.email = email
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                
                if let PlayerDictionary = snapshot.value as? [String:Any] {
                    if let imageURL = PlayerDictionary["ProfileImage"] as? String, let address1 = PlayerDictionary["Address Line 1"] as? String, let address2 = PlayerDictionary["Address Line 2"] as? String, let postcode = PlayerDictionary["Postcode"] as? String, let name = PlayerDictionary["Full Name"] as? String, let position = PlayerDictionary["Position"] as? String, let positionSide = PlayerDictionary["Position Side"] as? String, let teamId = PlayerDictionary["Team ID"] as? String {
                        
                        self.lblEmail.text = email
                        // self.tfEmail.text = email
                        
                        self.lblAddressLine1.text = address1
                        self.tfAddressLine1.text = address1
                        
                        self.lblAddressLine2.text = address2
                        self.tfAddressLine2.text = address2
                        
                        self.lblPostcode.text = postcode
                        self.tfPostcode.text = postcode
                        
                        self.lblPlayerName.text = name
                        self.position = position
                        self.positionSide = positionSide
                        
                        // GET THE IMAGE FROM THE PASSED URL
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
                                            self.ivProfilePic.image = image
                                        }
                                    }
                                }
                            }
                        }
                        task.resume()
                        
                        self.ivProfilePic.layer.cornerRadius = self.ivProfilePic.frame.size.width / 2
                        self.ivProfilePic.layer.masksToBounds = true
                        
                        if teamId == "" {
                            self.haveClub = false
                            self.freeAgentSettings()
                        } else {
                            self.haveClub = true
                            Database.database().reference().child("Teams").queryOrderedByKey().queryEqual(toValue: teamId).observe(.childAdded, with: { (snapshot) in
                                
                                if let TeamDictionary = snapshot.value as? [String:Any] {
                                    if let teamName = TeamDictionary["Team Name"] as? String {
                                        self.lblTeamName.text = teamName
                                        
                                        completionBlock(true)
                                        self.setSliders()
                                    }
                                }
                            })
                        }
                    }
                }
            })
        }
    }
    
    func setSliders () {
        
        print("11111111111 PSOTION SIDE: \(positionSide)")
        
        // SET THE SLIDERS TO THE CORRECT POSITION (POSITION SIDE)
        if positionSide == "Left" {
            slrPositionSide.value = 0
            sideActive(Left: UIColor.black, Centre: UIColor.gray, Right: UIColor.gray)
        } else if positionSide == "Centre" {
            slrPositionSide.value = 1
            sideActive(Left: UIColor.gray, Centre: UIColor.black, Right: UIColor.gray)
        } else {
            slrPositionSide.value = 2
            sideActive(Left: UIColor.gray, Centre: UIColor.gray, Right: UIColor.black)
        }
        
        // SET THE SLIDERS TO THE CORRECT POSITION (POSITION)
        if position == "Goal Keeper" {
            slrPosition.value = 0
            positionActive(GK: UIColor.black, DEF: UIColor.gray, MID: UIColor.gray, STR: UIColor.gray)
        } else if position == "Defender" {
            slrPosition.value = 1
            positionActive(GK: UIColor.gray, DEF: UIColor.black, MID: UIColor.gray, STR: UIColor.gray)
        } else if position == "Midfielder" {
            slrPosition.value = 2
            positionActive(GK: UIColor.gray, DEF: UIColor.gray, MID: UIColor.black, STR: UIColor.gray)
        } else {
            slrPosition.value = 3
            positionActive(GK: UIColor.gray, DEF: UIColor.gray, MID: UIColor.gray, STR: UIColor.black)
        }
        
        stopSpinner()
    }
    
    func sideActive (Left: UIColor, Centre: UIColor, Right: UIColor) {
        lblLEFT.textColor = Left
        lblCENTRE.textColor = Centre
        lblRIGHT.textColor = Right
    }
    
    func positionActive (GK: UIColor, DEF: UIColor, MID: UIColor, STR: UIColor) {
        lblGK.textColor = GK
        lblDEF.textColor = DEF
        lblMID.textColor = MID
        lblSTR.textColor = STR
    }
    
    @IBAction func slrPlayerPositionMoved(_ sender: Any) {
        if slrPosition.value >= 0 && slrPosition.value < 0.5 {
            //GK
            positionActive(GK: UIColor.black, DEF: UIColor.gray, MID: UIColor.gray, STR: UIColor.gray)
            self.position = "Goal Keeper"
        } else if slrPosition.value >= 0.5 && slrPosition.value < 1.5  {
            //DEF
            positionActive(GK: UIColor.gray, DEF: UIColor.black, MID: UIColor.gray, STR: UIColor.gray)
            self.position = "Defender"
        } else if slrPosition.value >= 1.5 && slrPosition.value < 2.5 {
            // MID
            positionActive(GK: UIColor.gray, DEF: UIColor.gray, MID: UIColor.black, STR: UIColor.gray)
            self.position = "Midfielder"
        } else {
            //STR
            positionActive(GK: UIColor.gray, DEF: UIColor.gray, MID: UIColor.gray, STR: UIColor.black)
            self.position = "Striker"
        }
    }
    
    @IBAction func slrPlayerPositionSideMoved(_ sender: Any) {
        if slrPositionSide.value >= 0 && slrPositionSide.value < 0.5 {
            //LEFT
            sideActive(Left: UIColor.black, Centre: UIColor.gray, Right: UIColor.gray)
            self.positionSide = "Left"
        } else if slrPositionSide.value >= 0.5 && slrPositionSide.value < 1.5 {
            //CENTRE
            sideActive(Left: UIColor.gray, Centre: UIColor.black, Right: UIColor.gray)
            self.positionSide = "Centre"
        } else {
            //RIGHT
            sideActive(Left: UIColor.gray, Centre: UIColor.gray, Right: UIColor.black)
            self.positionSide = "Right"
        }
    }
    
    @IBAction func btnEditAddressClicked(_ sender: Any) {
        if editAddress1Mode == true {
            tfAddressLine1.isHidden = false
            tfAddressLine2.isHidden = false
            tfPostcode.isHidden = false
            lblAddressLine1.isHidden = true
            lblAddressLine2.isHidden = true
            lblPostcode.isHidden = true
            btnEditAddress.setImage(#imageLiteral(resourceName: "upload.png"), for: .normal)
            editAddress1Mode = false
        } else {
            tfAddressLine1.isHidden = true
            tfAddressLine2.isHidden = true
            tfPostcode.isHidden = true
            lblAddressLine1.isHidden = false
            lblAddressLine2.isHidden = false
            lblPostcode.isHidden = false
            
            lblAddressLine1.text = tfAddressLine1.text
            lblAddressLine2.text = tfAddressLine2.text
            lblPostcode.text = tfPostcode.text
            self.address1 = tfAddressLine1.text!
            self.address2 = tfAddressLine2.text!
            self.postcode = tfPostcode.text!
            
            btnEditAddress.setImage(#imageLiteral(resourceName: "edit.png"), for: .normal)
            editAddress1Mode = true
            
            startSpinner()
            Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: self.email).observe(.childAdded) { (snapshot) in
                snapshot.ref.updateChildValues(["Address Line 1":self.address1, "Address Line 2":self.address2, "Postcode":self.postcode])
                Database.database().reference().child("Players").removeAllObservers()
            }
            stopSpinner()
            
        }
    }
    
    @IBAction func btnEditPositionClicked(_ sender: Any) {
        print("TAPPED")
        if editPositionMode == true {
            slrPosition.isEnabled = true
            btnEditPosition.setImage(#imageLiteral(resourceName: "upload.png"), for: .normal)
            editPositionMode = false
        } else {
            slrPosition.isEnabled = false
            btnEditPosition.setImage(#imageLiteral(resourceName: "edit.png"), for: .normal)
            editPositionMode = true
            
            //MAybe look if changed first?
            updatePlayerDetails(description: "Position", detail: self.position)
            
        }
    }
    
    @IBAction func btnPositionSideClicked(_ sender: Any) {
        print("TAPPED")
        if editPositionSideMode == true {
            slrPositionSide.isEnabled = true
            btnEditPositionSide.setImage(#imageLiteral(resourceName: "upload.png"), for: .normal)
            editPositionSideMode = false
        } else {
            slrPositionSide.isEnabled = false
            btnEditPositionSide.setImage(#imageLiteral(resourceName: "edit.png"), for: .normal)
            editPositionSideMode = true
            
            //MAybe look if changed first?
            updatePlayerDetails(description: "Position Side", detail: self.positionSide)

        }
    }

    
    func updatePlayerDetails(description: String, detail: String ) {
        startSpinner()
        Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: self.email).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues([description:detail])
            Database.database().reference().child("Players").removeAllObservers()
        }
        stopSpinner()
    }
    
    @IBAction func btnLeaveTeamCicked(_ sender: Any) {
        if self.haveClub {
            self.displayAlert(title: "Confirmation", message: "Are you sure you want to remove yourself from the team")
        } else {
            // NEED TO ADD SEGUE CODE
            print("SEGUE TO NEW PLACE TO JOIN TEAM")
        }
    }
    
    func removeTeamId(playerEmail : String) {
        Database.database().reference().child("Players").queryOrdered(byChild: "Email").queryEqual(toValue: playerEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["Team ID": ""])
            Database.database().reference().child("Players").removeAllObservers()
        }
        freeAgentSettings()
    }
    
    
    func freeAgentSettings() {
        lblTeamName.text = "Free Agent"
        btnLeaveJoin.setTitle("Join Team", for: .normal)
        btnLeaveJoin.backgroundColor = UIColor(red: 10/255, green: 200/255, blue: 30/255, alpha: 1.0)
    }
    
    
    func displayAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.removeTeamId(playerEmail : self.email)
            self.haveClub = false
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func startSpinner() {
        //MARK: Spinner
        print("START SPINNER CALLED")
        self.vLoading.isHidden = false
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = UIActivityIndicatorView.Style.gray
        view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopSpinner() {
        print("STOP SPINNER CALLED")
        self.vLoading.isHidden = true
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
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
