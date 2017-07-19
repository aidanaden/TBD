//
//  CustomKolodaView.swift
//  gameOfChats
//
//  Created by Aidan Aden on 15/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Koloda

let defaultTopOffset: CGFloat = 20
let defaultHorizontalOffset: CGFloat = 10
let defaultHeightRatio: CGFloat = 1.25
let backgroundCardHorizontalMarginMultiplier: CGFloat = 0.25
let backgroundCardScalePercent: CGFloat = 1.5

class CustomKolodaView: KolodaView {
    
    override func frameForCard(at index: Int) -> CGRect {
        if index == 0 {
//            let topOffset: CGFloat = defaultTopOffset
//            let xOffset: CGFloat = defaultHorizontalOffset
//            let width = (self.frame).width - 2 * defaultHorizontalOffset
//            let height = width * defaultHeightRatio
//            let yOffset: CGFloat = topOffset
//            let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
            
            return CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
//            return frame
        } else if index == 1 {
//            let horizontalMargin = -self.bounds.width * backgroundCardHorizontalMarginMultiplier
            let width = self.bounds.width * 1 //backgroundCardScalePercent
//            let height = width * defaultHeightRatio
            let height = self.bounds.height
            //            return CGRect(x: horizontalMargin, y: 0, width: width, height: height)
            return CGRect(x: 0, y: 0, width: width, height: height)
        }
        return CGRect.zero
    }
    
}

