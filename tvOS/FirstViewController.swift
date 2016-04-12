//
//  FirstViewController.swift
//  tvOS
//
//  Created by Max Gao on 05/04/16.
//  Copyright © 2016 Max Gao. All rights reserved.
//

import UIKit

class FirstViewController: UICollectionViewController, UISearchResultsUpdating {

    var series = [String]()
    var filteredSeries = [String]()
    static let storyboardIdentifier = "SearchResultsViewController"
    
    
    
    
    let originalCellSize = CGSizeMake(240, 292)
    let focusCellSize = CGSizeMake(260, 310)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        series = AppDelegate.series
        
    }
    

    
    var filterString = "" {
        didSet {
            // Return if the filter string hasn't changed.
            guard filterString != oldValue else { return }
            
            // Apply the filter or show all items if the filter string is empty.
            if filterString.isEmpty {
                filteredSeries = [String]()
            }
            else {
                filteredSeries.removeAll()
                ThreadManager.killAllThreads()
                filteredSeries = series.filter { $0.componentsSeparatedByString("-").joinWithSeparator(" ").localizedStandardContainsString(filterString) }
            }
            
            // Reload the collection view to reflect the changes.
            collectionView!.reloadData()
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredSeries.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ShowSerie", forIndexPath: indexPath) as? SeriesCollectionViewCell {
            
            let serie = filteredSeries[indexPath.row]
            
            cell.serie = serie as String
            cell.image.layer.cornerRadius = 8.0
            cell.image.clipsToBounds = true
            cell.initLabel()
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.mainScreen().scale
            
            cell.image.image = UIImage()
            let urlString = AppDelegate.ip + "/images/" + serie + ".png"
            cell.urlString = urlString
            
            if(ThreadManager.cache[cell.urlString] == nil) {
            
            if let url = NSURL(string: urlString) {
                    UIImage.asyncDownloadImageWithUrl(url, completionBlock: { (succeded, dimage) -> Void in
                        if succeded {
                            if cell.urlString == url.absoluteString {
                                ThreadManager.cache[cell.urlString] = dimage
                                cell.image.image = dimage
                            }
                        }
                    })
                }
            } else {
                cell.image.image = ThreadManager.cache[cell.urlString]
            }

            if cell.gestureRecognizers?.count == nil {
                let tap = UITapGestureRecognizer(target: self, action: "tapped:")
                tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
                cell.addGestureRecognizer(tap)
            }
            
            return cell
        } else {
            return SeriesCollectionViewCell()
        }

    }
    
    // MARK: UICollectionViewDelegate
    

    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let item = filteredSeries[indexPath.row]
        
        // Configure the cell.
        
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterString = searchController.searchBar.text ?? ""
    }

    
    func tapped(gesture: UITapGestureRecognizer) {
        if let cell = gesture.view as? SeriesCollectionViewCell {
            if let resultController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ShowInhalt") as? InhaltViewController {
                resultController.serie = cell.serie
                self.presentViewController(resultController, animated: true, completion: nil)
                
                
            }
            
        }
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if let previousItem = context.previouslyFocusedView as? SeriesCollectionViewCell {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                previousItem.image.frame.size = self.originalCellSize
                
            })
        }
        if let nextItem = context.nextFocusedView as? SeriesCollectionViewCell {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                nextItem.image.frame.size = self.focusCellSize
                
            })
        }
        
    }
    




}

extension UIImage {
    static func asyncDownloadImageWithUrl(url: NSURL, completionBlock: (succeeded: Bool, image: UIImage?) -> Void) {
        let request = NSMutableURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) in
            if error == nil {
                if let image = UIImage(data: data!) {
                    completionBlock(succeeded: true, image: image)
                }
            } else {
                completionBlock(succeeded: false, image: nil)
            }
            
        })
    }
}

