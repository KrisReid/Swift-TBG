//
//  FixtureDetailCollectionViewCell.swift
//  TBG
//
//  Created by Kris Reid on 03/02/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import UIKit

class FixtureDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ivProfilePic: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        ivProfilePic.layer.cornerRadius = ivProfilePic.frame.size.width / 2
        ivProfilePic.layer.masksToBounds = true
        
        
        
    }
    
}
