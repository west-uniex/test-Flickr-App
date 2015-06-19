//
//  Photo.swift
//  testFlickrApp
//
//  Created by Mykola on 6/18/15.
//  Copyright (c) 2015 The Kondratyuks. All rights reserved.
//

import Foundation
/*
<photo id="18279404944" owner="64634040@N02" secret="8fa4331dec" server="368" farm="1" title="Kyley Horton" ispublic="1" isfriend="0" isfamily="0" />
*/

public class Photo
{
    /*
    public private(set) var id      :   String = ""            // properties must be initialized
    public private(set) var owner   :   String = ""
    public private(set) var secret  :   String = ""
    public private(set) var server  :   String = ""
    public private(set) var farm    :   String = ""
    public private(set) var isPublic:   Bool   = false
    public private(set) var isFriend:   Bool   = false
    public private(set) var isFamily:   Bool   = false
    */
    
    public var id      :   String = ""            // properties must be initialized
    public var owner   :   String = ""
    public var secret  :   String = ""
    public var server  :   String = ""
    public var farm    :   String = ""
    public var title   :   String = ""
    public var isPublic:   Bool   = false
    public var isFriend:   Bool   = false
    public var isFamily:   Bool   = false
   
    
    // initializer
    /*
    public init (
                    id:      String,
                    owner   :   String,
                    secret  :   String,
                    server  :   String,
                    farm    :   String,
                    isPublic:   Bool,
                    isFriend:   Bool,
                    isFamily:   Bool
                )
    {
        self.id       = id
        self.owner    = owner;
        self.secret   = secret;
        self.server   = server;
        self.farm     = farm
        self.isPublic = isPublic;
        self.isFriend = isFriend;
        self.isFamily = isFamily;
        
    }
    */
        
}
