//
//  FirstViewController.swift
//  tvOS
//
//  Created by Max Gao on 05/04/16.
//  Copyright © 2016 Max Gao. All rights reserved.
//

import UIKit

class FirstViewController: UICollectionViewController, UISearchResultsUpdating {

    var series = [NSString]()
    var filteredSeries = [NSString]()
    static let storyboardIdentifier = "SearchResultsViewController"
    
    let originalCellSize = CGSizeMake(300, 370)
    let focusCellSize = CGSizeMake(320, 400)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSeries()
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
                    
                    if(!self.series.contains(final)) {
                        self.series.append(final)
                        print(final)
                    }
                    
                    
                }
            }
            
        } catch {
        }
        
        
        
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
            
            if cell.gestureRecognizers?.count == nil {
                let tap = UITapGestureRecognizer(target: self, action: "tapped:")
                tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
                cell.addGestureRecognizer(tap)
            }
            
            
            
            return cell
        }
        else {
            return SeriesCollectionViewCell()
        }

    }
    
    // MARK: UICollectionViewDelegate
    

    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let item = filteredSeries[indexPath.row]
        
        // Configure the cell.
        print(item)
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

