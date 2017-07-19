//
//  CustomKolodaOverlay.swift
//  gameOfChats
//
//  Created by Aidan Aden on 15/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "overlay_like"
private let overlayLeftImageName = "overlay_skip"

class CustomOverlayView: OverlayView {
    
    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
        }()
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = #imageLiteral(resourceName: "overlay_skip")
            case .right? :
                overlayImageView.image = #imageLiteral(resourceName: "overlay_like")
            default:
                overlayImageView.image = nil
            }
            
        }
    }
    
}
