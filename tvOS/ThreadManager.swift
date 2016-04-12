//
//  ThreadManager.swift
//  tvOS
//
//  Created by Max Gao on 09/04/16.
//  Copyright © 2016 Max Gao. All rights reserved.
//

import Foundation
import UIKit

public class ThreadManager {
    
    static var threads = [NSThread]()
    static var cache = [String : UIImage]()
    
    static func killAllThreads() {
    
        for thread : NSThread in threads {
            thread.cancel()
        }
        
    }
    
}
