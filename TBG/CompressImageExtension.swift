//
//  CompressImageExtension.swift
//  TBG
//
//  Created by Kris Reid on 25/11/2017.
//  Copyright © 2017 Kris Reid. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
//    func resized(withPercentage percentage: CGFloat) -> UIImage? {
//        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
//        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
//        defer { UIGraphicsEndImageContext() }
//        draw(in: CGRect(origin: .zero, size: canvasSize))
//        return UIGraphicsGetImageFromCurrentImageContext()
//    }
//
//    func resizedTo1MB() -> UIImage? {
//        guard let imageData = UIImagePNGRepresentation(self) else { return nil }
//
//        var resizingImage = self
//        var imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
//
//        while imageSizeKB > 1000 { // ! Or use 1024 if you need KB but not kB
//            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
//                let imageData = UIImagePNGRepresentation(resizedImage)
//                else { return nil }
//
//            resizingImage = resizedImage
//            imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
//        }
//
//        return resizingImage
//    }
    
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
}


