//
//  StrikerCollectionViewCell.swift
//  TBG
//
//  Created by Kris Reid on 06/02/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import UIKit

class StrikerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ivPlayerProfile: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        ivPlayerProfile.layer.cornerRadius = ivPlayerProfile.frame.size.width / 2
        ivPlayerProfile.layer.masksToBounds = true
        
    }
}
