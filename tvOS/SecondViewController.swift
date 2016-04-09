//
//  SecondViewController.swift
//  tvOS
//
//  Created by Max Gao on 05/04/16.
//  Copyright © 2016 Max Gao. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imagePath = fileInDocumentsDirectory("zurueck-in-die-zukunft.png")
        
        if (loadImageFromPath(imagePath) == nil) {
            
            button.alpha = 0

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                for serie: String in AppDelegate.series {
                    

                    let manager = NSFileManager.defaultManager()
                    let imagePath = self.fileInDocumentsDirectory(serie + ".png")
                    
                    if(manager.fileExistsAtPath(imagePath)) {
                        continue
                    }
                    
                    let tvdbid = self.fetchID(serie)
                    
                    if(tvdbid == "error") {
                        self.backupImage(serie)
                        continue
                    }
                    
                    self.downloadImage(serie, tvdbid: tvdbid)
                
                    
                    let backgroundPath = self.fileInDocumentsDirectory(serie + "_background" + ".png")
                    
                    if(manager.fileExistsAtPath(backgroundPath)) {
                        continue
                    }
                    
                    self.downloadBackground(serie, tvdbid: tvdbid)
                    
                    
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.button.alpha = 1
                    self.label.alpha = 0
                }
                
          
            });
            
        
            
            
        } else {
            label.alpha = 0
        }

        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClick(sender: AnyObject) {
        deleteContentsOfFolder()
    }

    public func deleteContentsOfFolder() {
        if let enumerator = NSFileManager.defaultManager().enumeratorAtPath(getDocumentsURL().path!) {
            while let item = enumerator.nextObject()
            {
                // itemURL
                if let itemURL = item as? NSURL
                {
                    do
                    {
                        try NSFileManager.defaultManager().removeItemAtURL(itemURL)
                    }
                    catch let error as NSError
                    {
                        print("JBSFile Exception: Could not delete item within folder.  \(error)")
                    }
                    catch
                    {
                        print("JBSFile Exception: Could not delete item within folder.")
                    }
                }
            }
        }
        }
    
    func saveImage (image: UIImage, path: String ) -> Bool{
        
        let pngImageData = UIImagePNGRepresentation(image)
        //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
        let result = pngImageData!.writeToFile(path, atomically: true)
        
        return result
        
    }
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
        
    }
    
    func loadImageFromPath(path: String) -> UIImage? {
        
        let image = UIImage(contentsOfFile: path)
        
        return image
        
    }
    
    func fetchID(var serie : String) -> String {
        do
        {
            if(serie.containsString("Marvel-s-")) {
                serie = serie.componentsSeparatedByString("Marvel-s-")[1]
            }
            
            let url = NSURL(string: "http://thetvdb.com/api/GetSeries.php?seriesname='" + serie.componentsSeparatedByString("-").joinWithSeparator("%20") + "'&language=de")
            let contents = try NSString(contentsOfURL: url!, usedEncoding: nil)
            
            //print(contents)
            let array = contents.componentsSeparatedByString("\n")
            var id = "error"
            
            for s : String in array {
                
                if(s.containsString("<id>")) {
                    
                    id = s.componentsSeparatedByString(">")[1].componentsSeparatedByString("<")[0]
                    break
                }
                
            }

            return id;
        } catch {
            return "error"
        }
    }
    
    func downloadImage(serie : String, tvdbid : String) {
        do
        {
            var imageurl = ""
            
            let url = NSURL(string: "http://webservice.fanart.tv/v3/tv/'+" + tvdbid +  "+'?api_key=9b5df109b2777f70b4956241d74778af")
            
            
            let contents = try NSString(contentsOfURL: url!, usedEncoding: nil)
            
            //print(contents)
            let array = contents.componentsSeparatedByString("\n")
            var b = false
            for s : String in array {
                
                if(s.containsString("tvposter") && s.containsString("url")) {
                    
                    
                    imageurl = s.componentsSeparatedByString("\"")[3]
                    b = true
                    
                    if(arc4random_uniform(2) == 0 ? true: false) {
                        break
                    }
                    
                }
                
            }
            
            if(b == true) {
                if let imageURL = NSURL(string: imageurl) {
                    if let fetchedImage = NSData(contentsOfURL: imageURL) {
                        let path = NSTemporaryDirectory() + "image_" + NSUUID().UUIDString
                        fetchedImage.writeToFile(path, atomically: false)
                        let endimg = UIImage(contentsOfFile: path)
                    
                        let imagePath = self.fileInDocumentsDirectory(serie + ".png")
                        self.saveImage(endimg!, path: imagePath)
                    }
                } else {
                    backupImage(serie)
                }
                
                
                
                
                
                
                
            } else {
                self.backupImage(serie)
                
            }
            
            
            
        } catch {
            self.backupImage(serie)
        }

    }
    
    func backupImage(serie : String) {
        do {
            let url = NSURL(string: "https://bs.to/serie/" + serie)
            let contents = try NSString(contentsOfURL: url!, usedEncoding: nil)
            let array = contents.componentsSeparatedByString("\n")
            var image = String()
            dispatch_async(dispatch_get_main_queue(), {
                self.label.text = ("Loading " + serie + " ...")
                print("Loading " + serie + " ...")
            });
            
            for s : String in array {
                
                if(s.containsString("s.bs.to/img/cover/")) {
                    
                    image = (s.componentsSeparatedByString("//")[1].componentsSeparatedByString("\"")[0])
                    
                    break
                    
                }
                
                
                
            }
            
            if let url = NSURL(string: "https://" + image) {
                if let data = NSData(contentsOfURL: url) {
                    let endimg = UIImage(data: data)
                    let imagePath = self.fileInDocumentsDirectory(serie + ".png")
                    self.saveImage(endimg!, path: imagePath)
                }
                
            }
            
        } catch {
            print("Error loading Image : " + serie)
        }

    }
    
    func downloadBackground(serie : String, tvdbid : String) {
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
                
                let imagePath = self.fileInDocumentsDirectory(serie + "_background" + ".png")
                self.saveImage(endimage, path: imagePath)
                
                // Image speichern
            }
            
        } catch { print("Error loading Background") }
        
    }
    
    
}

