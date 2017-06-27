//
//  Message.swift
//  gameOfChats
//
//  Created by Aidan Aden on 22/6/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var toUserId: String?
    var senderId: String?
    var text: String?
    var date: String?
    
    var messageImageWidth: NSNumber?
    var messageImageHeight: NSNumber?
    
    var imageURL: String?
    
    var videoURL: String?
    
    func chatPartnerId() -> String? {
        
        return senderId == FIRAuth.auth()?.currentUser?.uid ? toUserId : senderId
    }
    
    init(dictionary: [String: Any]) {
        super.init()
        
        toUserId = dictionary[kTOUSERID] as? String
        senderId = dictionary[kSENDERID] as? String
        text = dictionary[kTEXT] as? String
        date = dictionary[kDATE] as? String
        imageURL = dictionary[kIMAGEURL] as? String
        
        messageImageWidth = dictionary[kIMAGEWIDTH] as? NSNumber
        messageImageHeight = dictionary[kIMAGEHEIGHT] as? NSNumber
        
        videoURL = dictionary[kVIDEOURL] as? String
    }
    
}




