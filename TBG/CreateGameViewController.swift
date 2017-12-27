//
//  CreateGameViewController.swift
//  TBG
//
//  Created by Kris Reid on 26/12/2017.
//  Copyright © 2017 Kris Reid. All rights reserved.
//

import UIKit

class CreateGameViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var btnOpposition: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var btnDateOpenClose: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var tfVenue: UITextField!
    @IBOutlet weak var tfOpposition: UITextField!
    
    var dateMode = true
    var oppositionMode = true
    
    let teams = ["Avonmouth", "Shirehampton", "Welwyn"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnCreateGame(_ sender: Any) {
        print("Clicked")
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
    
    @IBAction func btnOppositionClicked(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.pickerView.isHidden = !self.pickerView.isHidden
            self.view.layoutIfNeeded()
        })
        
        if oppositionMode {
            oppositionMode = false
            btnOpposition.setTitle("Clear", for: .normal)
        } else {
            oppositionMode = true
            btnOpposition.setTitle("Pick Team", for: .normal)
        }
    }
    
    // Code for Date Picker
    @IBAction func datePickerAction(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let strDate = dateFormatter.string(from: datePicker.date)

        self.tfDate.text = String(strDate)
    }
    
    //code for Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teams.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teams[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tfOpposition.text = teams[row]
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
