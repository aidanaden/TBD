//
//  Constants.swift
//  gameOfChats
//
//  Created by Aidan Aden on 21/6/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import Foundation
import Firebase

let firebase = FIRDatabase.database().reference()
let storage = FIRStorage.storage().reference()

let kID = "id"
let kMESSAGES = "messages"
let kUSERS = "users"
let kNAME = "name"
let kEMAIL = "email"
let kPROFILEIMAGEURL = "profileImageUrl"
let kPROFILEIMAGES = "profileImages"
let kMESSAGEVIDEOS = "messageVideos"
let kMESSAGEIMAGES = "messageImages"
let kIMAGEWIDTH = "messageImageWidth"
let kIMAGEHEIGHT = "messageImageHeight"
let kIMAGEURL = "imageURL"
let kVIDEOURL = "videoURL"
let kTEXT = "text"
let kTOUSERID = "toUserId"
let kSENDERID = "senderId"
let kDATE = "date"
let kUSERMESSAGES = "user-messages"
let kSUCCESS = 2
let kIMAGEMESSAGE = "image message"
let kVIDEOMESSAGE = "video message"

let userCellId = "UserCell"

func customPlaceholder(placeholder: String) -> NSAttributedString {
    
    var myMutableStringTitle: NSAttributedString
    
    myMutableStringTitle = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName : UIColor.white.withAlphaComponent(0.7)])
    
    return myMutableStringTitle
}



