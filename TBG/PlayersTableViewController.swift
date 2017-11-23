//
//  PlayersTableViewController.swift
//  TBG
//
//  Created by Kris Reid on 23/11/2017.
//  Copyright © 2017 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseAuth

class PlayersTableViewController: UITableViewController {
    
    var email = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let managerEmail = Auth.auth().currentUser?.email {
            self.email = managerEmail
        }

    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 50
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = email

        return cell
    }
    


}
