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
    var players : [String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblOpposition.text = self.opposition
        
        setNavTitle(completionBlock: setNavTitleHandlerBlock)
    }
    
    let setNavTitleHandlerBlock: (Bool) -> () = { (isSuccess: Bool) in
        if isSuccess {
            print("Function is completed")
        }
    }
    
    func setNavTitle(completionBlock: (Bool) -> Void) {
        if self.opposition == "" {
            completionBlock(false)
        } else {
            completionBlock(true)
            self.navigationItem.title = self.opposition
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
