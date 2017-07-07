//
//  JSQMessagesController+JSQMessages.swift
//  gameOfChats
//
//  Created by Aidan Aden on 3/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import AVFoundation

extension JSQMessagesViewController {
    
    
    func createJSQMessage(message: Message) -> JSQMessage? {
        
        let jsqMessage: JSQMessage?
        
        if message.videoURL != nil {
            
            jsqMessage = createJSQVideoMessage(message: message)
            return jsqMessage
            
        } else if message.imageURL != nil {
            
            jsqMessage = createJSQImageMessage(message: message)
            return jsqMessage
            
        } else {
            
            jsqMessage = createJSQTextMessage(message: message)
            return jsqMessage
        }
    }
    
    func createJSQTextMessage(message: Message) -> JSQMessage? {
        
        let text = message.text
        let senderId = message.senderId
        let date = Double(message.date!)
        let actualDate = Date(timeIntervalSince1970: date)
        
        // change date from string Date type
        
        return JSQMessage(senderId: senderId, senderDisplayName: "", date: actualDate, text: text)
    }
    
    func createJSQImageMessage(message: Message) -> JSQMessage? {
        
        let senderId = message.senderId
        let date = Double(message.date!)
        let actualDate = Date(timeIntervalSince1970: date)
        let imageUrl = message.imageURL
        

        let mediaItem = TaillessPhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingOrIncoming(senderId: senderId!)
        
        let url = URL(string: imageUrl!)
        
        if let uRL = url {
            
            let resource = ImageResource(downloadURL: uRL)
            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                
                mediaItem?.image = image
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
        }
        
        return JSQMessage(senderId: senderId, senderDisplayName: "", date: actualDate, media: mediaItem)
        
    }
    
    func createJSQVideoMessage(message: Message) -> JSQMessage? {
        
        let senderId = message.senderId
        let date = Double(message.date!)
        let actualDate = Date(timeIntervalSince1970: date)
        let videoUrl = message.videoURL
        let url = URL(string: videoUrl!)
        let thumbnailUrl = URL(string: message.imageURL!)

        let mediaItem = VideoMessage(withFileUrl: url!, maskOutgoing: returnOutgoingOrIncoming(senderId: senderId!))
        
        downloadVideo(videoUrl: videoUrl!) { (readyToPlay, fileName) in
            
            let videoFileUrl = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
            
            // download thumbnail
           
            mediaItem.status = kSUCCESS
            mediaItem.fileURL = videoFileUrl
            
            let resource = ImageResource(downloadURL: thumbnailUrl!)
            
            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil, completionHandler: { (img, err, cacheType, url) in
                
                mediaItem.image = img
            
                self.collectionView.reloadData()
            })
            
//            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: senderId, senderDisplayName: "", date: actualDate, media: mediaItem)
        
    }
    
    func returnOutgoingOrIncoming(senderId: String) -> Bool {
        
        if senderId == FIRAuth.auth()?.currentUser!.uid as! String {
            // message is outgoing
            return true
        } else {
            // message is incoming
            return false
        }
    }
}
