//
//  FixturesTableViewCellMore.swift
//  TBG
//
//  Created by Kris Reid on 25/04/2019.
//  Copyright © 2019 Kris Reid. All rights reserved.
//

import UIKit

class FixturesTableViewCellMore: UITableViewCell {
    
    @IBOutlet weak var lblOpposition: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblVenue: UILabel!
    @IBOutlet weak var ivHomeAway: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

