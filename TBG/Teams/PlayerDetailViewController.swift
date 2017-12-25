//
//  PlayerDetailViewController.swift
//  TBG
//
//  Created by Kris Reid on 25/11/2017.
//  Copyright © 2017 Kris Reid. All rights reserved.
//

import UIKit

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
    
    var playerName = ""
    var newImage: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPlayerName.text = playerName
        
        // TRY AND CHANGE CODE TO PASS THE IMAGE RATHER THAN CALLING AGAIN !!!!!!!
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
    }
    
    
    @IBAction func slrPlayerPositionMoved(_ sender: Any) {
        if slrPlayerPosition.value >= 0 && slrPlayerPosition.value < 0.5 {
            //GK
            lblGK.textColor = UIColor.black
            lblDEF.textColor = UIColor.gray
            lblMID.textColor = UIColor.gray
            lblSTR.textColor = UIColor.gray
            btnUpdate.isHidden = false
        } else if slrPlayerPosition.value >= 0.5 && slrPlayerPosition.value < 1.5  {
            //DEF
            lblGK.textColor = UIColor.gray
            lblDEF.textColor = UIColor.black
            lblMID.textColor = UIColor.gray
            lblSTR.textColor = UIColor.gray
            btnUpdate.isHidden = false
        } else if slrPlayerPosition.value >= 1.5 && slrPlayerPosition.value < 2.5 {
            // MID
            lblGK.textColor = UIColor.gray
            lblDEF.textColor = UIColor.gray
            lblMID.textColor = UIColor.black
            lblSTR.textColor = UIColor.gray
            btnUpdate.isHidden = false
        } else {
            //STR
            lblGK.textColor = UIColor.gray
            lblDEF.textColor = UIColor.gray
            lblMID.textColor = UIColor.gray
            lblSTR.textColor = UIColor.black
            btnUpdate.isHidden = false
        }
    }
    
    @IBAction func slrPlayerPositionSideMoved(_ sender: Any) {
        if slrPlayerPositionSide.value >= 0 && slrPlayerPositionSide.value < 0.5 {
            //LEFT
            lblLeft.textColor = UIColor.black
            lblCentre.textColor = UIColor.gray
            lblRight.textColor = UIColor.gray
            btnUpdate.isHidden = false
        } else if slrPlayerPositionSide.value >= 0.5 && slrPlayerPositionSide.value < 1.5 {
            //CENTRE
            lblLeft.textColor = UIColor.gray
            lblCentre.textColor = UIColor.black
            lblRight.textColor = UIColor.gray
            btnUpdate.isHidden = false
        } else {
            //RIGHT
            lblLeft.textColor = UIColor.gray
            lblCentre.textColor = UIColor.gray
            lblRight.textColor = UIColor.black
            btnUpdate.isHidden = false
        }
    }
    
    @IBAction func btnUpdateSelected(_ sender: Any) {
        
    }
    
}
