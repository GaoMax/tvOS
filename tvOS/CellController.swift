//
//  CellController.swift
//  tvOS
//
//  Created by Max Gao on 06/04/16.
//  Copyright © 2016 Max Gao. All rights reserved.
//

import Foundation
import UIKit

public class CellController {
    
    static var cached = [String: UIImage]()
    
    static func isCached(serie : String) -> Bool {
        for s in (cached as NSDictionary).allKeys {
            if(s as! String == serie) {
                return true
            }
        }
        
        return false
        
    }
    
    static func getCell(serie : String) -> UIImage? {
        if(cached.keys.contains(serie)) {
            return cached[serie]
        }
        return nil
        
    }
    
    static func cache(serie : String, image : UIImage) {
        cached[serie] = image
    }
    
    
    
}
