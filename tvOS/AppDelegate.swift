//
//  AppDelegate.swift
//  tvOS
//
//  Created by Max Gao on 05/04/16.
//  Copyright © 2016 Max Gao. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static var series = [String]()
    
    static let ip = "http://maxgao.de"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        loadSeries()
        if let tabController = window?.rootViewController as? UITabBarController {
            tabController.viewControllers?.append(packagedSearchController())
        }
        
        return true
    }
    
    

    
    func loadSeries() {
        do {
            let url = NSURL(string: "https://bs.to/serie/")
            let contents = try NSString(contentsOfURL: url!, usedEncoding: nil)
            
            //print(contents)
            var array = contents.componentsSeparatedByString("\n")
            
            for var s : String in array {
                
                if(!s.containsString("<li><a href=\"serie/")) {
                    array.removeAtIndex(array.indexOf(s)!)
                    
                } else {
                    s = s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet());
                    let index1 = s.endIndex.advancedBy(-9)
                    let part1 = s.substringToIndex(index1)
                    let index2 = part1.startIndex.advancedBy(19)
                    let part2 = part1.substringFromIndex(index2)
                    
                    let final = part2.componentsSeparatedByString("\"")[0]
                    
                    if(!AppDelegate.series.contains(final)) {
                        AppDelegate.series.append(final)
                    }
                }
            }
            
        } catch {
        }
        
        
        
    }
    

    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func packagedSearchController() -> UIViewController {
        // Load a `SearchResultsViewController` from its storyboard.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let searchResultsController = storyboard.instantiateViewControllerWithIdentifier(FirstViewController.storyboardIdentifier) as? FirstViewController else {
            fatalError("Unable to instatiate a SearchResultsViewController from the storyboard.")
        }
        
        /*
         Create a UISearchController, passing the `searchResultsController` to
         use to display search results.
         */
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.searchBar.placeholder = NSLocalizedString("Enter keyword (e.g. iceland)", comment: "")
        
        // Contain the `UISearchController` in a `UISearchContainerViewController`.
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        searchContainer.title = NSLocalizedString("Search", comment: "")
        
        // Finally contain the `UISearchContainerViewController` in a `UINavigationController`.
        let searchNavigationController = UINavigationController(rootViewController: searchContainer)
        return searchNavigationController
    }
    
    


}

