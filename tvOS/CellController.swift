//
//  CellController.swift
//  tvOS
//
//  Created by Max Gao on 06/04/16.
//  Copyright © 2016 Max Gao. All rights reserved.
//

import Foundation

public class CellController {
    
    static var cached = [String: SeriesCollectionViewCell]()
    
    static func isCached(serie : String) -> Bool {
        for s in (cached as NSDictionary).allKeys {
            if(s as! String == serie) {
                return true
            }
        }
        
        return false
        
    }
    
    static func getCell(serie : String, ocell : SeriesCollectionViewCell) -> SeriesCollectionViewCell {

        print(cached[serie]!.serie + "was loaded from cache with the name : " +  serie)
        
        for s in (cached as NSDictionary).allKeys {
            if(s as! String == "The-Flash") {
                print("GEFUNDEN")
            }
        }
        
        return cached[serie]!
    }
    
    static func cache(serie : String, cell : SeriesCollectionViewCell) {
        cached[serie] = cell
    }
    
    
    
}
