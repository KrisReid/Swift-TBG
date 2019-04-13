//
//  AlternativeSignUpViewController.swift
//  TBG
//
//  Created by Kris Reid on 12/04/2019.
//  Copyright © 2019 Kris Reid. All rights reserved.
//

import UIKit

class AlternativeSignUpViewController : UIViewController, UINavigationControllerDelegate, UIScrollViewDelegate  {
    
    @IBOutlet weak var btnSubmt: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var svLogin: UIScrollView!
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
        }
    }
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var vSlide4: UIView!
    var slides:[Slide] = [];
    
    override func viewDidLoad() {
        
        //SET THE CONTAINER
        vContainer.layer.borderWidth = 1
        vContainer.layer.borderColor = UIColor.white.cgColor
        vContainer.layer.cornerRadius = 10
        vContainer.frame = CGRect(x: 0 , y: 0, width: UIScreen.main.bounds.height / 2.5, height: UIScreen.main.bounds.height / 2)
        vContainer.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        
        //CANCEL BUTTON
        btnCancel.layer.borderWidth = 1
        btnCancel.layer.borderColor = UIColor.white.cgColor
        btnCancel.layer.cornerRadius = CGFloat(10)
        btnCancel.clipsToBounds = true
        btnCancel.layer.maskedCorners = [.layerMinXMaxYCorner]
        let cancelY = vContainer.frame.height - (btnCancel.frame.height)
        btnCancel.frame = CGRect(x: 0, y: cancelY, width: vContainer.frame.width/2, height: 50)
        
        //SUBMIT BUTTON
        btnSubmt.layer.borderWidth = 1
        btnSubmt.layer.borderColor = UIColor.white.cgColor
        btnSubmt.layer.cornerRadius = CGFloat(10)
        btnSubmt.clipsToBounds = true
        btnSubmt.layer.maskedCorners = [.layerMaxXMaxYCorner]
        let submitX = vContainer.frame.width / 2 - 1
        let submitY = vContainer.frame.height - btnSubmt.frame.height
        btnSubmt.frame = CGRect(x: submitX, y: submitY, width: vContainer.frame.width/2 + 1, height: 50)
        
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
        
        pageControl.frame = CGRect(x: 0, y: vContainer.frame.height - 80, width: vContainer.frame.width, height: 20)
        
    }
    
    
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        
    }
    
    
    func createSlides() -> [Slide] {
        
        let slide1:Slide = Bundle.main.loadNibNamed("AccountSlide", owner: self, options: nil)?.first as! Slide
        
        slide1.ivProfile.layer.cornerRadius = slide1.ivProfile.frame.size.width / 2
        slide1.ivProfile.layer.masksToBounds = true
        
        slide1.btnProfile.layer.cornerRadius = slide1.btnProfile.frame.size.width / 2
        slide1.btnProfile.layer.masksToBounds = true
        let myColor = UIColor.white
        slide1.btnProfile.layer.borderColor = myColor.cgColor
        slide1.btnProfile.layer.borderWidth = 1.0
        
        
        
        let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide2.lblAge.text = "A real-life bear"
        slide2.lblName.text = "Did you know that Winnie the chubby little cubby was based on a real, young bear in London"
        
        let slide3:Slide = Bundle.main.loadNibNamed("Slide2", owner: self, options: nil)?.first as! Slide
        slide3.lblToner.text = "A real-life bear"
        
        
        return [slide1, slide2, slide3]
    }
    
    func setupSlideScrollView(slides : [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: vContainer.frame.width, height: vContainer.frame.height - 50)
        scrollView.contentSize = CGSize(width: vContainer.frame.width * CGFloat(slides.count), height: vContainer.frame.height - 50)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: vContainer.frame.width * CGFloat(i), y: 0, width: vContainer.frame.width, height: vContainer.frame.height - 50)
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/vContainer.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        
    }
    
    
    
}
