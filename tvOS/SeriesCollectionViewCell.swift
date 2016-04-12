//
//  SeriesCollectionViewCell.swift
//  Burning-Series-tvOS
//
//  Created by Max Gao on 11.12.15.
//  Copyright © 2015 Max Gao. All rights reserved.
//

import UIKit

class SeriesCollectionViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    var serie = ""
    var urlString = ""
    
    func initLabel() {
        
        label.text = serie.componentsSeparatedByString("-").joinWithSeparator(" ")
        
    }

}


public extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSizeMake(1, 1)) {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }  
}



