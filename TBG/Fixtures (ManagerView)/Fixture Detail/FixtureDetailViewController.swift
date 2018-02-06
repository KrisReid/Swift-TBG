//
//  FixtureDetailViewController.swift
//  TBG
//
//  Created by Kris Reid on 26/01/2018.
//  Copyright © 2018 Kris Reid. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FixtureDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var cvGoalkeeper: UICollectionView!
    @IBOutlet weak var cvDefender: UICollectionView!
    @IBOutlet weak var cvMid: UICollectionView!
    
    @IBOutlet weak var cvStriker: UICollectionView!
    
    var opposition: String = ""
    
    var playerKeys : Dictionary<String, Any> = [:]
    var goalkeepers : [DataSnapshot] = []
    var defenders : [DataSnapshot] = []
    var midfielders : [DataSnapshot] = []
    var strikers : [DataSnapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = opposition
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Run a get data function that reloads the data?
        cvGoalkeeper.reloadData()
        cvDefender.reloadData()
        cvMid.reloadData()
        cvStriker.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.cvDefender {
            return self.defenders.count
        } else if collectionView == self.cvMid {
            return self.midfielders.count
        } else if collectionView == self.cvGoalkeeper {
            return self.goalkeepers.count
        } else {
            return self.strikers.count
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView==self.cvDefender {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? FixtureDetailCollectionViewCell {
                
                if self.defenders == [] {
                    // Do Nothing - Figure out hoe to reload better as this is shit
                } else {
                    let snapshot = defenders[indexPath.row]
                    print(snapshot)
                    if let PlayerDictionary = snapshot.value as? [String:Any] {
                        if let name = PlayerDictionary["Full Name"] as? String {
                            if let imageURL = PlayerDictionary["ProfileImage"] as? String {
                                print(self.playerKeys)
                                
                                var availability = ""
                                
                                for a in playerKeys {
                                    if snapshot.key == a.key {
                                        if a.value as? String == "Available" {
                                            availability = "Available"
                                        } else if a.value as? String == "Maybe" {
                                            availability = "Maybe"
                                        } else {
                                            availability = "Unavailable"
                                        }
                                    }
                                }
                                
                                cell.lblFullName.text = name
                                
                                let url = URL(string: imageURL)
                                let request = NSMutableURLRequest(url: url!)
                                
                                let task = URLSession.shared.dataTask(with: request as URLRequest) {
                                    data, response, error in
                                    
                                    if error != nil {
                                        print(error ?? "Error")
                                    } else {
                                        if let data = data {
                                            DispatchQueue.main.async {
                                                if let image = UIImage(data: data) {
                                                    cell.ivProfilePic.image = image
                                                    
                                                    cell.ivProfilePic.layer.borderWidth = 2
                                                    
                                                    if availability == "Available" {
                                                        print("AVAILABLE")
                                                        cell.ivProfilePic.layer.borderColor = UIColor.init(red: 30/255, green: 190/255, blue: 30/255, alpha: 1.0).cgColor
                                                    } else if availability == "Maybe" {
                                                        print("MAYBE")
                                                        cell.ivProfilePic.layer.borderColor = UIColor.orange.cgColor
                                                    } else {
                                                        print("UNAVAILABLE")
                                                        cell.ivProfilePic.layer.borderColor = UIColor.red.cgColor
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                                task.resume()
                                return cell
                            }
                        }
                    }
                }
            }
        } else if collectionView == self.cvGoalkeeper {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gkCell", for: indexPath) as? GoalkeeperCollectionViewCell {
                
                if self.goalkeepers == [] {
                    // Do Nothing - Figure out hoe to reload better as this is shit
                } else {
                    let snapshot = goalkeepers[indexPath.row]
                    //print(snapshot)
                    if let PlayerDictionary = snapshot.value as? [String:Any] {
                        if let name = PlayerDictionary["Full Name"] as? String {
                            if let imageURL = PlayerDictionary["ProfileImage"] as? String {
                                //print(self.playerKeys)
                                
                                var availability = ""
                                
                                for a in playerKeys {
                                    if snapshot.key == a.key {
                                        if a.value as? String == "Available" {
                                            availability = "Available"
                                        } else if a.value as? String == "Maybe" {
                                            availability = "Maybe"
                                        } else {
                                            availability = "Unavailable"
                                        }
                                    }
                                }
                                
                                cell.lblFullName.text = name
                                
                                let url = URL(string: imageURL)
                                let request = NSMutableURLRequest(url: url!)
                                
                                let task = URLSession.shared.dataTask(with: request as URLRequest) {
                                    data, response, error in
                                    
                                    if error != nil {
                                        print(error ?? "Error")
                                    } else {
                                        if let data = data {
                                            DispatchQueue.main.async {
                                                if let image = UIImage(data: data) {
                                                    cell.ivPlayerProfile.image = image
                                                    
                                                    cell.ivPlayerProfile.layer.borderWidth = 2
                                                    
                                                    if availability == "Available" {
                                                        print("AVAILABLE")
                                                        cell.ivPlayerProfile.layer.borderColor = UIColor.init(red: 30/255, green: 190/255, blue: 30/255, alpha: 1.0).cgColor
                                                    } else if availability == "Maybe" {
                                                        print("MAYBE")
                                                        cell.ivPlayerProfile.layer.borderColor = UIColor.orange.cgColor
                                                    } else {
                                                        print("UNAVAILABLE")
                                                        cell.ivPlayerProfile.layer.borderColor = UIColor.red.cgColor
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                                task.resume()
                                return cell
                            }
                        }
                    }
                }
            }
        } else if collectionView == self.cvMid {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "midCell", for: indexPath) as? MidCollectionViewCell {
                
                if self.midfielders == [] {
                    // Do Nothing - Figure out hoe to reload better as this is shit
                } else {
                    let snapshot = midfielders[indexPath.row]
                    //print(snapshot)
                    if let PlayerDictionary = snapshot.value as? [String:Any] {
                        if let name = PlayerDictionary["Full Name"] as? String {
                            if let imageURL = PlayerDictionary["ProfileImage"] as? String {
                                //print(self.playerKeys)
                                
                                var availability = ""
                                
                                for a in playerKeys {
                                    if snapshot.key == a.key {
                                        if a.value as? String == "Available" {
                                            availability = "Available"
                                        } else if a.value as? String == "Maybe" {
                                            availability = "Maybe"
                                        } else {
                                            availability = "Unavailable"
                                        }
                                    }
                                }
                                
                                cell.lblFullName.text = name
                                
                                let url = URL(string: imageURL)
                                let request = NSMutableURLRequest(url: url!)
                                
                                let task = URLSession.shared.dataTask(with: request as URLRequest) {
                                    data, response, error in
                                    
                                    if error != nil {
                                        print(error ?? "Error")
                                    } else {
                                        if let data = data {
                                            DispatchQueue.main.async {
                                                if let image = UIImage(data: data) {
                                                    cell.ivPlayerProfile.image = image
                                                    
                                                    cell.ivPlayerProfile.layer.borderWidth = 2
                                                    
                                                    if availability == "Available" {
                                                        print("AVAILABLE")
                                                        cell.ivPlayerProfile.layer.borderColor = UIColor.init(red: 30/255, green: 190/255, blue: 30/255, alpha: 1.0).cgColor
                                                    } else if availability == "Maybe" {
                                                        print("MAYBE")
                                                        cell.ivPlayerProfile.layer.borderColor = UIColor.orange.cgColor
                                                    } else {
                                                        print("UNAVAILABLE")
                                                        cell.ivPlayerProfile.layer.borderColor = UIColor.red.cgColor
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                                task.resume()
                                return cell
                            }
                        }
                    }
                }
            }
        } else if collectionView == self.cvStriker {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "strCell", for: indexPath) as? StrikerCollectionViewCell {
                
                if self.strikers == [] {
                    // Do Nothing - Figure out hoe to reload better as this is shit
                } else {
                    let snapshot = strikers[indexPath.row]
                    //print(snapshot)
                    if let PlayerDictionary = snapshot.value as? [String:Any] {
                        if let name = PlayerDictionary["Full Name"] as? String {
                            if let imageURL = PlayerDictionary["ProfileImage"] as? String {
                                //print(self.playerKeys)
                                
                                var availability = ""
                                
                                for a in playerKeys {
                                    if snapshot.key == a.key {
                                        if a.value as? String == "Available" {
                                            availability = "Available"
                                        } else if a.value as? String == "Maybe" {
                                            availability = "Maybe"
                                        } else {
                                            availability = "Unavailable"
                                        }
                                    }
                                }
                                
                                cell.lblFullName.text = name
                                
                                let url = URL(string: imageURL)
                                let request = NSMutableURLRequest(url: url!)
                                
                                let task = URLSession.shared.dataTask(with: request as URLRequest) {
                                    data, response, error in
                                    
                                    if error != nil {
                                        print(error ?? "Error")
                                    } else {
                                        if let data = data {
                                            DispatchQueue.main.async {
                                                if let image = UIImage(data: data) {
                                                    cell.ivPlayerProfile.image = image
                                                    
                                                    cell.ivPlayerProfile.layer.borderWidth = 2
                                                    
                                                    if availability == "Available" {
                                                        print("AVAILABLE")
                                                        cell.ivPlayerProfile.layer.borderColor = UIColor.init(red: 30/255, green: 190/255, blue: 30/255, alpha: 1.0).cgColor
                                                    } else if availability == "Maybe" {
                                                        print("MAYBE")
                                                        cell.ivPlayerProfile.layer.borderColor = UIColor.orange.cgColor
                                                    } else {
                                                        print("UNAVAILABLE")
                                                        cell.ivPlayerProfile.layer.borderColor = UIColor.red.cgColor
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                                task.resume()
                                return cell
                            }
                        }
                    }
                }
            }
        }
        return UICollectionViewCell()
    }
    
    
}
