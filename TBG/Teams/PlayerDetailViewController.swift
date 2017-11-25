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
    
    var playerName = ""
    //var playerProfilePic: UIImage

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPlayerName.text = playerName
        // ivPlayerProfilePicture.image = playerProfilePic
        
        ivPlayerProfilePicture.layer.cornerRadius = ivPlayerProfilePicture.frame.size.width / 2
        ivPlayerProfilePicture.layer.masksToBounds = true

    }


}
