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
        
        let imagePath = "zurueck-in-die-zukunft.png"
        
        if (loadImage(imagePath) == nil) {
            
            button.alpha = 0

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                for serie: String in AppDelegate.series {
                    
                    let imagePath = serie + ".png"
                    
                    if(self.loadImage(imagePath) != nil) {
                        continue
                    }
                    
                    let tvdbid = self.fetchID(serie)
                    
                    if(tvdbid == "error") {
                        self.backupImage(serie)
                        continue
                    }
                    
                    self.downloadImage(serie, tvdbid: tvdbid)
                    
                    let backgroundPath = serie + "_background" + ".png"
                    
                    if(self.loadImage(backgroundPath) != nil) {
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
        if let enumerator = NSFileManager.defaultManager().enumeratorAtPath(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) {
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
        uploadImage(image, serie: path)
        return result
        
    }
    
    
    func fileInDocumentsDirectory(filename: String) -> String {
        return filename
        
    }
    
    
    func fetchID(var serie : String) -> String {
        do
        {
            if(serie.containsString("Marvel-s-")) {
                serie = serie.componentsSeparatedByString("Marvel-s-")[1]
            }
            
            if(serie.containsString("DC's")) {
                serie = serie.componentsSeparatedByString("DC's")[1]
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
    
    func loadImage(name : String) -> UIImage? {
        if let url = NSURL(string: AppDelegate.ip + "/images/" + name) {
            if let data = NSData(contentsOfURL: url) {
                if let endimg = UIImage(data: data) {
                    return endimg 
                }
                
            }
            
        }
        return nil
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
    
    func uploadImage(image : UIImage, serie : String)
    {
        
        let myUrl = NSURL(string: AppDelegate.ip + "/test.php");
        
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        
        let param = [
            "firstName"  : "Max",
            "lastName"    : "Gao",
            "userId"    : "1"
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(image, 1)
        
        if(imageData==nil)  { return; }
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary, name: serie)
        
        
        

        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            
            /*
             if let parseJSON = json {
             var firstNameValue = parseJSON["firstName"] as? String
             println("firstNameValue: \(firstNameValue)")
             }
             */
            
        }
        
        task.resume()
        
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String, name : String) -> NSData {
        var body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = name
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    
    
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
