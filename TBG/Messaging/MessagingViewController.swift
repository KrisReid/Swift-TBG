//
//  MessagingViewController.swift
//  TBG
//
//  Created by Kris Reid on 21/04/2019.
//  Copyright © 2019 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth

class MessagingViewController: UIViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func btnLogOut(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
