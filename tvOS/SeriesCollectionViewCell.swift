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
    var tvdbid = ""
    var imageurl = ""
    var images = [UIImage]()
    
    func initLabel() {
        
        label.text = serie.componentsSeparatedByString("-").joinWithSeparator(" ")
        backupImage()

        
    }
    
    
    
    func backupImage() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        do {
            let url = NSURL(string: "https://bs.to/serie/" + self.serie)
            let contents = try NSString(contentsOfURL: url!, usedEncoding: nil)
            
            //print(contents)
            let array = contents.componentsSeparatedByString("\n")
            var image = String()
            
            for s : String in array {
                
                if(s.containsString("Cover")) {
                    
                    image = (s.componentsSeparatedByString("//")[1].componentsSeparatedByString("\"")[0])
                    
                }
                
                
                
            }
                
                if let url = NSURL(string: "https://" + image) {
                    if let data = NSData(contentsOfURL: url) {
                        let endimg = UIImage(data: data)
                        
                        self.image.image = endimg
                    }//make sure your image in this url does exist, otherwise unwrap in a if let check
                    
                }
                


            
            self.tvdbid = "no"
            
        } catch {
            print("Error loading Image"
            )
        }
            
        };

    }

    
}


