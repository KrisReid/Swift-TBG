//
//  FixturesTableViewController.swift
//  TBG
//
//  Created by Kris Reid on 01/01/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import UIKit

class FixturesTableViewController: UITableViewController {
    

    

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    @IBAction func btnAddFixture(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addFixtureSegue", sender: nil)
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 50
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PlayersTableViewCell {
//
//        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = "BOB"

        return cell
    }
 

}
