//
//  CreateGameViewController.swift
//  TBG
//
//  Created by Kris Reid on 26/12/2017.
//  Copyright © 2017 Kris Reid. All rights reserved.
//

import UIKit

class CreateGameViewController: UIViewController {
    
    @IBOutlet weak var btnDateOpenClose: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var tfVenue: UITextField!
    
    var dateMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func btnDateTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.datePicker.isHidden = !self.datePicker.isHidden
            self.view.layoutIfNeeded()
            
        })
        
        if dateMode {
            dateMode = false
            btnDateOpenClose.setTitle("Clear", for: .normal)
        } else {
            dateMode = true
            btnDateOpenClose.setTitle("Pick Date", for: .normal)
        }
    }
    

    @IBAction func datePickerAction(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let strDate = dateFormatter.string(from: datePicker.date)

        self.tfDate.text = String(strDate)
        
    }
    
    //closes the keyboard when you touch white space
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //enter button will close the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    


}
