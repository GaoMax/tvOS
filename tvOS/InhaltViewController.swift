//
//  InhaltViewController.swift
//  Burning-Series-tvOS
//
//  Created by Max Gao on 11.12.15.
//  Copyright © 2015 Max Gao. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class InhaltViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    var serie = ""
    var tvdbid = ""
    
    var images = [UIImage]()
    
    var seasons = [String]()
    var season = ""
    
    let focusCellSize = CGRectMake(54, 84, 311, 399)
    let originalCellSize = CGRectMake(54, 180, 330, 420)
    let originalFotoSize = CGSizeMake(279, 398)
    let focusFotoSize = CGSizeMake(279 * 1.1, 398 * 1.1)
    var originallabel = CGRectMake(0,0,0,0)
    
    var episode = false
    var episodes = [String]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadSeasons()
        
        if(!tvdbid.containsString("no")) {
            downloadBackground()
        }



    }
    
    func loadEpisodes() {
        
        do {
            let urlstring = "https://bs.to/serie/" + serie + "/" + season + "/"
            let url = NSURL(string: urlstring)
            let contents = try NSString(contentsOfURL: url!, usedEncoding: nil)
            let array = contents.componentsSeparatedByString("\n")
            var seasonst = [String]()
            var b = false;
            
            for s : String in array {
                
                if(s.containsString("<th title=\"Episode in Serie\">#</th>")) {
                    b = true;
                    continue
                }
                
                if(b == true) {
                    if(!s.containsString("</table>")) {
                        if(s.containsString("href=\"") && s.containsString("Streamcloud")) {
                            seasonst.append(s)
                        }
                        
                    } else {
                        b = false;
                        break
                    }
                    
                    
                }
                
                
                
            }
            
            for var s : String in seasonst {
                s = s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet());
                let link = s.componentsSeparatedByString("\"")[1]
                episodes.append(link)
                
                
            }
        } catch {
            
        }
        
    }
    
    func loadSeasons() {
        do {
            let urlstring = "https://bs.to/serie/" + serie
            let url = NSURL(string: urlstring)
            let contents = try NSString(contentsOfURL: url!, usedEncoding: nil)
            
            //print(contents)
            let array = contents.componentsSeparatedByString("\n")
            var seasonst = [String]()
            var b = false;
            
            for s : String in array {
                
                if(s.containsString("<ul class=\"pages\">")) {
                    b = true;
                    continue
                }
                
                if(b == true) {
                    if(!s.containsString("</ul>")) {
                        
                        if(!s.containsString("<li class=\"button\"")) {
                            seasonst.append(s)
                        }
                    } else {
                        
                        b = false;
                        break
                    }
                    
                    
                }
                
                
                
            }
            
            for var s : String in seasonst {
                
                s = s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet());
                let index1 = s.endIndex.advancedBy(-8)
                
                let part2 = s.componentsSeparatedByString(">")[2].componentsSeparatedByString("<")[0]
                seasons.append(part2)
                
                
            }
            
        }catch {
            
        }
        
        seasons = seasons.filter() { !$0.isEmpty }
        
        
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if(episode == false) {
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ShowSeason", forIndexPath: indexPath) as? SeasonsCollectionViewCell {
                
                let season = seasons[indexPath.row]
                
                cell.seasonLabel.text = season
                cell.seasonLabel.layer.masksToBounds = true
                cell.seasonLabel.layer.cornerRadius = 8.0
                cell.seasonLabel.font = cell.seasonLabel.font.fontWithSize(20)
                cell.seasonLabel.frame = originalCellSize
                
                
                if cell.gestureRecognizers?.count == nil {
                    let tap = UITapGestureRecognizer(target: self, action: "tapped:")
                    tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
                    cell.addGestureRecognizer(tap)
                }
                
                
                
                return cell
            }
            else {
                return SeasonsCollectionViewCell()
            }
        } else {
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ShowEpisode", forIndexPath: indexPath) as? EpisodesCollectionViewCell {
            
                let episode = episodes[indexPath.row]
                cell.episode = episode
                var text = episode.componentsSeparatedByString("/")[3].componentsSeparatedByString("-")
                let number  = text[0]
                text.removeAtIndex(0)
                
                let finaltext = number + ": " + text.joinWithSeparator(" ")
                cell.label.text = finaltext
                cell.label.layer.masksToBounds = true
                cell.label.layer.cornerRadius = 8.0
                //cell.image.image = images.sample()
                cell.image.layer.cornerRadius = 8.0
                cell.image.clipsToBounds = true
                
                
                if cell.gestureRecognizers?.count == nil {
                    let tap = UITapGestureRecognizer(target: self, action: "tapped:")
                    tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
                    cell.addGestureRecognizer(tap)
                }
                
                
                return cell
            } else {
                return EpisodesCollectionViewCell()
            }
        }
        

    }
    
    func tapped(gesture: UITapGestureRecognizer) {
        if let cell = gesture.view as? SeasonsCollectionViewCell {
            episode = true
            season = cell.seasonLabel.text!
            loadEpisodes()
            self.collectionView.reloadData()
            
        } else if let cell = gesture.view as? EpisodesCollectionViewCell {
            
            do {
                let url = NSURL(string: "https://bs.to/" + cell.episode)
                let contents = try NSString(contentsOfURL: url!, usedEncoding: nil)
                let array = contents.componentsSeparatedByString("\n")
                var link = ""
                print(url)
                for s : String in array {
                    
                    if(s.containsString("streamcloud.eu")) {
                        link = s
                        
                    }
                    
                }
                
                link = link.componentsSeparatedByString("\"")[1]
                fetchVideo(link)
                
            } catch {
                print("NoData")
                
            }

            
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(episode == true) {
            return episodes.count
        } else {
            return seasons.count
        }
        
        
        
    }
    
    func downloadBackground() {
        do
        {
            
            let url = NSURL(string: "http://webservice.fanart.tv/v3/tv/'+" + tvdbid +  "+'?api_key=9b5df109b2777f70b4956241d74778af")
            let contents = try NSString(contentsOfURL: url!, usedEncoding: nil)
            
            //print(contents)
            let array = contents.componentsSeparatedByString("\n")
            var image = String()
            for s : String in array {
                
                if(s.containsString("showbackground") && s.containsString("url")) {
                    
                    
                    image = s.componentsSeparatedByString("\"")[3]
                    break
                    
                }
                
            }
            let imageURL = NSURL(string: image)
            if let fetchedImage = NSData(contentsOfURL: imageURL!) {
                
                let endimage = UIImage(data: fetchedImage)!
                
                let color = UIColor(patternImage: endimage)
                
                self.view.backgroundColor = color
            }
            
        } catch { print("Error loading Image") }
        
    }
    
    func backupImage() {
        do {
            let url = NSURL(string: "https://bs.to/serie/" + serie)
            let contents = try NSString(contentsOfURL: url!, usedEncoding: nil)
            
            //print(contents)
            let array = contents.componentsSeparatedByString("\n")
            var image = String()
            
            for s : String in array {
                
                if(s.containsString("Cover")) {
                    
                    image = (s.componentsSeparatedByString("//")[1].componentsSeparatedByString("\"")[0])
                    
                }
                
                
                
            }
            
            let imageURL = NSURL(string: "http://" + image)
            let fetchedImage = try! NSData(contentsOfURL: imageURL!)
            let path = NSTemporaryDirectory() + "image_" + NSUUID().UUIDString
            fetchedImage!.writeToFile(path, atomically: false)
            let endimg = UIImage(contentsOfFile: path)
            
            self.images.append(endimg!)
            
            tvdbid = "no"
            
        } catch {
            print("Error loading Image"
            )
        }
        
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if let previousItem = context.previouslyFocusedView as? SeasonsCollectionViewCell {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                previousItem.seasonLabel.frame = self.originalCellSize
            })
        }
        if let nextItem = context.nextFocusedView as? SeasonsCollectionViewCell {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                nextItem.seasonLabel.frame = self.focusCellSize
                
            })
        }
        if let previousItem = context.previouslyFocusedView as? EpisodesCollectionViewCell {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                previousItem.image.frame.size = self.originalFotoSize
                previousItem.label.frame = CGRectMake(8, 512, 402, 21)
            })
        }
        if let nextItem = context.nextFocusedView as? EpisodesCollectionViewCell {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                nextItem.image.frame.size = self.focusFotoSize
                nextItem.label.frame = CGRectMake(8 * 1.1, 512 * 1.1, 402 * 1.1, 21 * 1.1)
            })
        }
        
    }
    func fetchVideo(s : String) {
        print(s)
        SwiftSpinner.show("Loading...")
        dispatch_async(dispatch_get_main_queue(), {
            // code here
            
            do {
                let url = NSURL(string: s)
                let contents = try NSString(contentsOfURL: url!, usedEncoding: nil)
                
                
                let pat1 = self.matchesForRegexInText("<input type=\"hidden\" name=\"fname\" value=\"(.*?)\">", text: contents as String).componentsSeparatedByString("value=")[1].componentsSeparatedByString("\"")[1]
                let pat2 = self.matchesForRegexInText("<input type=\"hidden\" name=\"hash\" value=\"(.*?)\">", text: contents as String).componentsSeparatedByString("value=")[1].componentsSeparatedByString("\"")[1]
                let pat3 = self.matchesForRegexInText("<input type=\"hidden\" name=\"id\" value=\"(.*?)\">", text: contents as String).componentsSeparatedByString("value=")[1].componentsSeparatedByString("\"")[1]
                let pat4 = self.matchesForRegexInText("<input type=\"submit\" name=\"imhuman\" id=\"btn_download\" class=\"button gray\" value=\"(.*?)\">", text: contents as String).componentsSeparatedByString("value=")[1].componentsSeparatedByString("\"")[1]
                let pat6 = self.matchesForRegexInText("<input type=\"hidden\" name=\"referer\" value=\"(.*?)\">", text: contents as String).componentsSeparatedByString("value=")[1].componentsSeparatedByString("\"")[1]
                let pat7 = self.matchesForRegexInText("<input type=\"hidden\" name=\"usr_login\" value=\"(.*?)\">", text: contents as String).componentsSeparatedByString("value=")[1].componentsSeparatedByString("\"")[1]
                
                let post = "fname=" + pat1 + "&hash=" + pat2 + "&id=" + pat3 + "&imhuman=" + pat4 + "&op=" + "download2" + "&referer=" + pat6 + "&usr_login=" + pat7
                
                
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    let session = NSURLSession.sharedSession()
                    let request = NSMutableURLRequest(URL: url!)
                    request.HTTPMethod = "POST"
                    request.HTTPBody = post.dataUsingEncoding(NSUTF8StringEncoding)!
                    
                    
                    let task = session.dataTaskWithRequest(request) { data, response, error in
                        
                        let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        
                        let content = dataString?.componentsSeparatedByString("\n")
                        var link = ""
                        for s : String in content! {
                            
                            if(s.containsString("file: \"")) {
                                link = s.componentsSeparatedByString("\"")[1]
                                
                                
                                
                            }
                            
                        }
                        
                        print(link)
                        
                        
                        
                        try! self.playVideo(link)
                        
                        
                    }
                    task.resume()
                    
                }
                
                
                
            } catch {
                
            }
        })
    }
    
    func matchesForRegexInText(regex: String!, text: String!) -> String {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matchesInString(text,
                                                options: [], range: NSMakeRange(0, nsString.length))
            let matches = results.map { nsString.substringWithRange($0.range)}
            if (matches.count > 0) {
                return matches[0]
            } else {
                return ""
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return ""
        }
    }

    
        private func playVideo(s: String) throws {
        
        SwiftSpinner.hide()
        
        
        let player = AVPlayer(URL: NSURL(string: s)!)
        
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.presentViewController(playerController, animated: true) {
            
            player.play()
            
            
        }
        
        
        
        
        
    }

   


}

extension Array {
    func sample() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
