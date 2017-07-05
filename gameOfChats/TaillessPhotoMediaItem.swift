//
//  CustomMediaItem.swift
//  gameOfChats
//
//  Created by Aidan Aden on 5/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//


import UIKit
import JSQMessagesViewController

class TaillessPhotoMediaItem: JSQPhotoMediaItem {
    
    override func mediaView() -> UIView? {
        
        if let imageView = super.mediaView() as? UIImageView {
            
            let masker = JSQMessagesMediaViewBubbleImageMasker(bubbleImageFactory: JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegularTailless(), capInsets: UIEdgeInsets.zero))
            masker?.applyIncomingBubbleImageMask(toMediaView: imageView)
            
            return imageView
        }
        
        return nil
    }
}
