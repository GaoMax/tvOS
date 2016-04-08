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
    
    
    
    
    let originalCellSize = CGSizeMake(300, 370)
    let focusCellSize = CGSizeMake(320, 400)
    
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
            
            var ncell = cell
            
            ncell.serie = serie as String
            ncell.image.layer.cornerRadius = 8.0
            ncell.image.clipsToBounds = true
            ncell.initLabel()


            if ncell.gestureRecognizers?.count == nil {
                let tap = UITapGestureRecognizer(target: self, action: "tapped:")
                tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
                ncell.addGestureRecognizer(tap)
            }
            
            
            
            return ncell
        }
        else {
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
                resultController.tvdbid = cell.tvdbid
                resultController.images = cell.images
                self.presentViewController(resultController, animated: true, completion: nil)
                
                
            }
            
        }
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if let previousItem = context.previouslyFocusedView as? SeriesCollectionViewCell {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                previousItem.image.frame.size = self.originalCellSize
                previousItem.label.frame = CGRectMake(70, 384, 180, 40)
                
            })
        }
        if let nextItem = context.nextFocusedView as? SeriesCollectionViewCell {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                nextItem.image.frame.size = self.focusCellSize
                nextItem.label.frame = CGRectMake(70 * 1.1, 384 * 1.1, 180 * 1.1, 21 * 1.1)
                
            })
        }
        
    }
    





}

