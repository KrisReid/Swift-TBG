//
//  Slide.swift
//  TBG
//
//  Created by Kris Reid on 12/04/2019.
//  Copyright © 2019 Kris Reid. All rights reserved.
//

import UIKit

class Slide: UIView {
//class Slide: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    
    @IBOutlet weak var lblToner: UILabel!
    
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var btnProfile: UIButton!
    
    
    @IBAction func btnProfileSelected(_ sender: Any) {
        print("11111111111")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePickerController.allowsEditing = true
//        self.present(imagePickerController, animated: true, completion: nil)
    }
    
}


