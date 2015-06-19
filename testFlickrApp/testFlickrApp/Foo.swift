//
//  Foo.swift
//  testFlickrApp
//
//  Created by Mykola on 6/18/15.
//  Copyright (c) 2015 The Kondratyuks. All rights reserved.
//

import UIKit
import Foundation

class Foo: UIViewController,  NSXMLParserDelegate
{
    var parser             = NSXMLParser()
    var photos              = NSMutableArray()
    
    var currentElementName  = NSString()
    
    var photoDictionary     = NSMutableDictionary()
    var photoString         = NSMutableString()
    
    //MARK:
    //MARK: - XML PARSING
    
    func beginParsing(dataFromServer: NSData)
    {
        parser   = NSXMLParser(data: dataFromServer)
        parser.delegate = self
        parser.parse()
    }
    
    /*
    original:
    <photo id="18244554094" owner="48644388@N04" secret="f5ceafb437" server="3707" farm="4" title="Sheva" ispublic="1" isfriend="0" isfamily="0" />
    */
    
    func parser (
        parser: NSXMLParser,
        didStartElement
        elementName: String,
        namespaceURI: String?,
        qualifiedName
        qName: String?,
        attributes
        attributeDict: [NSObject : AnyObject]
        )
    {
        println("start elementName: \(elementName)\n")
        currentElementName = elementName
        if (elementName as NSString).isEqualToString("photos")
        {
            photos = NSMutableArray.alloc()
            photos = []
        }
        
        if (elementName as NSString).isEqualToString("photo")
        {
            photoString   = NSMutableString.alloc()
            photoString   = ""
        }
        
        
    }
    
    func parser (
        parser: NSXMLParser,
        didEndElement
        elementName: String,
        namespaceURI: String?,
        qualifiedName
        qName: String?
        )
    {
        println("end elementName: \(elementName)\n")
        
        if (elementName as NSString).isEqualToString("photos")
        {
            if !photoDictionary.isEqual(nil)
            {
                photos.addObject(photoDictionary)
            }
        }
        
        if (elementName as NSString).isEqualToString("photo")
        {
            if !photoString.isEqual(nil)
            {
                println("end photoString: \(photoString)\n")
                
                // id pars ... id="18270715644"
                let rangeId      = photoString.rangeOfString("id=\"")
                let rangeIdValue = NSMakeRange( rangeId.location + rangeId.length , 11)
                let idString     = photoString.substringWithRange(rangeIdValue)
                
                println("end idString: \(photoString)\n")
                
                if !idString.isEqual(nil)
                {
                    photoDictionary.setObject(idString, forKey: "id")
                }
                
                println("end photoDictionary: \(photoDictionary)\n")
            }
        }
        
        
    }
    
    /*
    original:
    <photo id="18244554094" owner="48644388@N04" secret="f5ceafb437" server="3707" farm="4" title="Sheva" ispublic="1" isfriend="0" isfamily="0" />
    */
    
    func parser (
        parser: NSXMLParser,
        foundCharacters
        string: String?
        )
    {
        println("foundCharacters: \(string)\n")
        if currentElementName.isEqualToString("photo")
        {
            photoString.appendString(string!)
            println("photoString: \(photoString)\n")
        }
    }
    
    func parser(
        parser: NSXMLParser,
        foundIgnorableWhitespace
        whitespaceString: String
        )
    {
        println("foundCharacters: \(whitespaceString)\n")
    }
    
    func parser(
        parser: NSXMLParser,
        foundAttributeDeclarationWithName
        attributeName: String,
        forElement
        elementName: String,
        //type
        type: String?,
        //defaultValue
        defaultValue: String?
        )
    {
        println("foundAttributeDeclarationWithName    attributeName: \(attributeName)\n")
        println("foundAttributeDeclarationWithName    elementName  : \(elementName)\n")
        println("foundAttributeDeclarationWithName    type         : \(type)\n")
        
        return;
        
    }
    
}
