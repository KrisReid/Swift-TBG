//
//  MidCollectionViewCell.swift
//  TBG
//
//  Created by Kris Reid on 05/02/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import UIKit

class MidCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var ivPlayerProfile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        ivPlayerProfile.layer.cornerRadius = ivPlayerProfile.frame.size.width / 2
        ivPlayerProfile.layer.masksToBounds = true
        
        
    }
    
}
