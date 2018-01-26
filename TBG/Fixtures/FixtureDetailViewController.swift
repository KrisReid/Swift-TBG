//
//  FixtureDetailViewController.swift
//  TBG
//
//  Created by Kris Reid on 26/01/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import UIKit

class FixtureDetailViewController: UIViewController {
    
    @IBOutlet weak var lblOpposition: UILabel!
    
    var opposition: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblOpposition.text = self.opposition

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
