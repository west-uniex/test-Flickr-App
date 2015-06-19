//
//  ViewController.swift
//  testFlickrApp
//
//  Created by Mykola on 6/18/15.
//  Copyright (c) 2015 The Kondratyuks. All rights reserved.
//

import UIKit
import Foundation


//  Simple text box, you type in a word, it performs a query on flickr images api,
//  and shows the first result


// flickr API Key:  9bca9377c3b682883162498e7db35e0a

//         Secret:  36095f1de945c8cf

//  https://www.flickr.com/auth-72157654642109801

//  code 396-007-594   
//       514-870-629



// https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=9bca9377c3b682883162498e7db35e0a&tags=girl

class ViewController: UIViewController, NSURLSessionDelegate
{

    var listPhotoDesc: Array<Photo> = []
    
    var urlOfDownloadedImage: NSURL = NSURL()
    
    var session: NSURLSession!
    
    var loadingView:          UIView                  = UIView()
    var netActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var randomGirlButton: UIButton!
    
    //MARK:
    //MARK: - VIEWS LIFESTYLE METHODS
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        var width :CGFloat = self.view.frame.size.width;
        width = width/2.0
        
        
        var buttonCenter: CGPoint = self.randomGirlButton.center
        
        buttonCenter.x = width
        self.randomGirlButton.center = buttonCenter
        
        self.imageView.contentMode = .ScaleAspectFit
        
        
        
        var viewFrame : CGRect = self.view.frame
        self.loadingView = UIView.init(frame: viewFrame)
        self.loadingView.backgroundColor = UIColor.blackColor()
        self.loadingView.alpha = 0.1
        //init!(activityIndicatorStyle style: UIActivityIndicatorViewStyle)
        self.netActivityIndicator   = UIActivityIndicatorView.init( activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        netActivityIndicator.startAnimating()
        netActivityIndicator.center = self.loadingView.center
        self.loadingView.addSubview( netActivityIndicator)
        
        self.view.addSubview(loadingView)
        loadingView.alpha = 0
        
        
        
        makeGeT_HTTP_Request_To_Flickr_API("girl");
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        var width :CGFloat = self.view.frame.size.width;
        width = width/2.0
        
        //var buttonFrame : CGRect = self.randomGirlButton.frame
        var buttonCenter: CGPoint = self.randomGirlButton.center
        
        buttonCenter.x = width
        self.randomGirlButton.center = buttonCenter
        self.loadingView.frame       = self.view.frame
        
        self.loadingView.center          = self.view.center
        self.netActivityIndicator.center = self.view.center
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:
    //MARK: - WORK WITH Flickr API

    func makeGeT_HTTP_Request_To_Flickr_API (
                                                tag: NSString
                                            )
    {
        let httpMethod = "GET"
    
        /* We have a 15 second timeout for our connection */
        //let timeout = 15
        
        /* You can choose your own URL here */
        var urlAsString = "https://api.flickr.com/services/rest/"
        
        urlAsString += "?method=flickr.photos.search"
        urlAsString += "&api_key=9bca9377c3b682883162498e7db35e0a"
        let tags = "&tags=" + (tag as String)
        urlAsString += tags
        urlAsString += "&per_page=500"
        urlAsString += "&page=3"
        let url = NSURL(string: urlAsString)
        
        /* Set the timeout on our request here */
        let urlRequest = NSMutableURLRequest(
                                                URL            : url!,
                                                cachePolicy    : .ReloadIgnoringLocalAndRemoteCacheData,
                                                timeoutInterval: 15.0
                                            );
    
        urlRequest.HTTPMethod = httpMethod
        
        let queue = NSOperationQueue()
        
        self.loadingView.alpha = 1
    
        NSURLConnection.sendAsynchronousRequest(
                                                    urlRequest,
                                                    queue: queue,
                                                    completionHandler:
                                                    {
                                                        (
                                                            response: NSURLResponse!,
                                                                data: NSData!,
                                                                error: NSError!
                                                        ) in
                                                    
                                                        if data.length > 0 && error == nil
                                                        {
                                                            let responceString = NSString(
                                                                                            data    : data,
                                                                                            encoding: NSUTF8StringEncoding
                                                                                         );
                                                            println("responceString = \(responceString)")
                                                            //self.beginParsing(data)
                                                            
                                                            self.listPhotoDesc = self.makeParsingResponceFromServerString(responceString!);
                                                            
                                                            let fistPhoto = self.listPhotoDesc.first
                                                            
                                                            self.urlOfDownloadedImage = self.createURL_FromPhotoDesc (fistPhoto!)
                                                            
                                                            self.downloadImageByURL(self.urlOfDownloadedImage);
                                                            
                                                        }
                                                        else if data.length == 0 && error == nil
                                                        {
                                                            println("Nothing was downloaded")
                                                        }
                                                        else if error != nil
                                                        {
                                                            println("Error happened = \(error)")
                                                        }
                                                    }
                                                );

    }

    //MARK:
    //MARK: -  PARSING BY SELF METHOD
    /*
    original:
    <photo id="18244554094" owner="48644388@N04" secret="f5ceafb437" server="3707" farm="4" title="Sheva" ispublic="1" isfriend="0" isfamily="0" />
    */
    
    func makeParsingResponceFromServerString ( responceFromServerString: NSString ) -> Array<Photo>
    {
        var resultsArray = [NSArray]()
        var listPhoto    = [Photo] ()
        
        var result     = NSArray.alloc()
        let separator  = NSCharacterSet.whitespaceCharacterSet();

        //
        var localResponceFromServerString = responceFromServerString.copy() as! NSString
        
        do
        {
            // cut off  each
            
            // id pars ... id="18270715644"
            //let rangeId      = mutCopyForCutting.rangeOfString("<photo id=")
            let rangeBeginTag = localResponceFromServerString.rangeOfString("<photo id=")
            
            if rangeBeginTag.location == NSNotFound
            {
                break;
            }
            
            localResponceFromServerString = localResponceFromServerString.substringFromIndex(rangeBeginTag.location) as NSString
            
            let rangeEndTag = localResponceFromServerString.rangeOfString(" />")
            
            let rangeCutting = NSMakeRange( 0 , rangeEndTag.location + 3)
            let photoString  = localResponceFromServerString.substringWithRange(rangeCutting) as NSString
            println("photoString: \(photoString)\n")
            
            //
            result = photoString.componentsSeparatedByCharactersInSet( separator) as NSArray;
            println("result: \(photoString)\n")
            
            var propertyString: NSString = ""
            var thePhotoClass : Photo    = Photo.init()
            
            if result.count != 11
            {
                localResponceFromServerString = localResponceFromServerString.substringFromIndex(rangeCutting.length)
                continue
            }
        
            
            for var i = 0; i < result.count; i++
            {
                // ...
                propertyString = result [i] as! NSString
                println("propertyString: \(propertyString)\n")
                
                //TODO: CHECK THEN ARRAY DO NOT CREATING CORREECT
                //for character in propertyString
                //{
                //    println(character)
                //}
                //if  no " "
                
                //localResponceFromServerString = localResponceFromServerString.substringFromIndex(rangeCutting.length)
                
                
                if propertyString.rangeOfString("id").location != NSNotFound
                {
                    let separatingArray  = propertyString.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: "=\""))
                    let idValue :String = separatingArray[2] as! String
                    
                    thePhotoClass.id = idValue
                    //pause()
                }
                
                if propertyString.rangeOfString("owner").location != NSNotFound
                {
                    let separatingArray  = propertyString.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: "=\""))
                    let ownerValue :String = separatingArray[2] as! String
                    
                    thePhotoClass.owner = ownerValue
                    sleep(0);
                }
                
                if propertyString.rangeOfString("secret").location != NSNotFound
                {
                    let separatingArray  = propertyString.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: "=\""))
                    let secretValue :String = separatingArray[2] as! String
                    
                    thePhotoClass.secret = secretValue
                    
                    sleep(0)
                }
                
                if propertyString.rangeOfString("server").location != NSNotFound
                {
                    let separatingArray  = propertyString.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: "=\""))
                    let serverValue :String = separatingArray[2] as! String
                    
                    thePhotoClass.server = serverValue
                    
                    sleep(0)
                }
                
                if propertyString.rangeOfString("farm").location != NSNotFound
                {
                    let separatingArray  = propertyString.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: "=\""))
                    let farmValue :String = separatingArray[2] as! String
                    
                    thePhotoClass.farm = farmValue
                    
                    sleep(0)
                }
                
                let rangeOfTitle = propertyString.rangeOfString("title=")
                if  rangeOfTitle.location != NSNotFound
                {
                    //let separatingArray  = propertyString.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: "=\""))
                    //let titleValue :String = separatingArray[2] as! String
                    var titleValue :String = propertyString.substringFromIndex(rangeOfTitle.length)
                    //titleValue = titleValue.substringToIndex(count(titleValue) - 2 )

                    thePhotoClass.title = titleValue
                    
                    sleep(0)
                }
                
                if propertyString.rangeOfString("ispublic").location != NSNotFound
                {
                    let separatingArray  = propertyString.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: "=\""))
                    let isPublicValue :String = separatingArray[2] as! String
                    
                    if isPublicValue.toInt() == 1
                    {
                        thePhotoClass.isPublic = true
                    }
                    else
                    {
                        thePhotoClass.isPublic = false
                    }
        
                    sleep(0)
                }

                if propertyString.rangeOfString("isfriend=").location != NSNotFound
                {
                    let separatingArray  = propertyString.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: "=\""))
                    let isFriendValue :String = separatingArray[2] as! String
                    
                    if isFriendValue.toInt() == 1
                    {
                        thePhotoClass.isFriend = true
                    }
                        else
                    {
                            thePhotoClass.isFriend = false
                    }
                    
                    sleep(0)
                }


                if propertyString.rangeOfString("isfamily=").location != NSNotFound
                {
                    let separatingArray  = propertyString.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: "=\""))
                    let isFamilyValue :String = separatingArray[2] as! String
                    
                    if isFamilyValue.toInt() == 1
                    {
                        thePhotoClass.isFamily = true
                    }
                        else
                    {
                        thePhotoClass.isFamily = false
                    }
                    
                    sleep(0)
                }
            }
            
            resultsArray.append(result)
            
            listPhoto.append(thePhotoClass)
            //
            localResponceFromServerString = localResponceFromServerString.substringFromIndex(rangeCutting.length)
            
        } while  localResponceFromServerString.rangeOfString("photo id=").location != NSNotFound
        
        //println("take resultsArray: \(resultsArray)\n")
        
        println("take listPhoto: \(listPhoto)\n")
        //return resultsArray;
        return listPhoto
    }
    
    //MARK:
    //MARK: -  CREATE URL FOR DOWNLOADING IMAGE FROM  FLICKR
    
    func createURL_FromPhotoDesc ( photoDesc:  Photo ) -> NSURL
    {
        //let numberOfChickens = 3
        //var myString = "John has \(numberOfChickens) chickens."
        //Result is "John has 3 chickens."
        
        //https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
        //
        //https://farm1.staticflickr.com/2/1418878_1e92283336_m.jpg
        //
        //farm-id: 1
        //server-id: 2
        //photo-id: 1418878
        //secret: 1e92283336
        //size: m
        
        var urlString: String  = "https://farm\(photoDesc.farm).staticflickr.com/\(photoDesc.server)/\(photoDesc.id)_\(photoDesc.secret).jpg"
        println("urlString: \(urlString) \n")
        
        let url = NSURL(string: urlString)
        
        return url!
    }

    
    //MARK:
    //MARK: -  DOWNLOADING IMAGE FROM  FLICKR METHOD
    
    
    func downloadImageByURL ( imageURL:  NSURL )
    {
        let task = session.dataTaskWithURL(
                                            imageURL,
                                            completionHandler:
                                            {
                                                [weak self] (
                                                                dataFrom: NSData!,
                                                                response: NSURLResponse!,
                                                                error   : NSError!
                                                            ) in
        
                                                /* We got our data here */
                                                println("Done")
        
                                                //self!.session.finishTasksAndInvalidate()
                                                
                                                // start show  photo or message about failed downloading
                                                
                                                self?.loadingView.alpha = 0
                                                
                                                let imagePhoto = UIImage.init( data: dataFrom)
                                                
                                                dispatch_async(
                                                                dispatch_get_main_queue(),
                                                                {
                                                                    [weak self] in
                                                    
                                                                    var message = "Finished downloading your content"
                                                    
                                                                    if error != nil
                                                                    {
                                                                        message = "Failed to download your content"
                                                                        self!.displayAlertWithTitle("Done", message: message);
                                                                    }
                                                    
                                                                    //self!.displayAlertWithTitle("Done", message: message);
                                                                    
                                                                    self!.imageView.image = imagePhoto;
                                                    
                                                                }
                                                            )

        
                                            }
                                         )
        task.resume()

    }

    //MARK:
    //MARK: -  CONFORMS NSURLSessionDelegate
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    
        /* Create our configuration first */
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 15.0
    
        /* Now create our session which will allow us to create the tasks */
        session = NSURLSession (
                                    configuration   : configuration,
                                    delegate        : self,
                                    delegateQueue   : nil
                               )
    
    }
    
    
    
    //MARK:
    //MARK: -  Just a little method to help us display alert dialogs to the user

    func displayAlertWithTitle(
                                title   : String,
                                message : String
                              )
    {
        let controller = UIAlertController(
                                            title           : title,
                                            message         : message,
                                            preferredStyle  : .Alert
                                          )
        
        controller.addAction(
                                UIAlertAction(
                                                title: "OK",
                                                style: .Default,
                                                handler: nil
                                             )
                            )
        
        presentViewController (
                                controller      ,
                                animated    : true,
                                completion  : nil
                              )
        
    }
    
    //MARK:
    //MARK: -  IB ACTIONS
    
    @IBAction func serachButtonDidTap(sender: AnyObject)
    {
        
        let size = self.listPhotoDesc.count;
        //arc4random_uniform() or  arc4random()
        
        //let randomIndex = arc4random_uniform(size)
        //var randomNumber = arc4random()
        //randomNumber =  randomNumber%randomNumber
        
        var k: Int = random() % size;
         println("random index: \(k)\n")
        
        let randomPhoto = self.listPhotoDesc[k]
        
        self.urlOfDownloadedImage = self.createURL_FromPhotoDesc (randomPhoto)
        
        self.downloadImageByURL(self.urlOfDownloadedImage);
    }
    
}


