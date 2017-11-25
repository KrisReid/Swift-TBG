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


}
