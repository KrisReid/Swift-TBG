//
//  FixturesTableViewCell.swift
//  TBG
//
//  Created by Kris Reid on 10/01/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import UIKit

class FixturesTableViewCell: UITableViewCell {
    
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
