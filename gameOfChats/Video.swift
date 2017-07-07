//
//  Video.swift
//  gameOfChats
//
//  Created by Aidan Aden on 4/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class VideoMessage: JSQMediaItem {
    
    var image: UIImage?
    var videoImageView: UIImageView?
    var status: Int?
    var fileURL: URL?
    
    init(withFileUrl: URL, maskOutgoing: Bool) {
        
        super.init(maskAsOutgoing: maskOutgoing)
        
        fileURL = withFileUrl
        videoImageView = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mediaView() -> UIView! {
        
        if let st = status {
            
            if st == 1 {
                
                print("Downloading...")
                return nil
            }
            
            if st == 2 && (self.videoImageView == nil) { // initializes the whole video message stuff
                print("Success!")
                
                let size = self.mediaViewDisplaySize()
                let icon = UIImage.jsq_defaultPlay().jsq_imageMasked(with: UIColor.white)
                
                let iconView = UIImageView(image: icon)
                
                iconView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                iconView.contentMode = UIViewContentMode.center
                
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                imageView.contentMode = UIViewContentMode.scaleAspectFill
                imageView.clipsToBounds = true
                imageView.addSubview(iconView)
                
                let masker = JSQMessagesMediaViewBubbleImageMasker(bubbleImageFactory: JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegularTailless(), capInsets: UIEdgeInsets.zero))
                masker?.applyIncomingBubbleImageMask(toMediaView: imageView)
                self.videoImageView = imageView
            }
        }
        return self.videoImageView
    }
    
}
