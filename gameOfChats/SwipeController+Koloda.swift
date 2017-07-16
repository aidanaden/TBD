//
//  SwipeController+Koloda.swift
//  gameOfChats
//
//  Created by Aidan Aden on 15/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import pop
import Koloda


extension SwipeController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        //        myKolodaView.resetCurrentCardIndex()
//        let position = myKolodaView.currentCardIndex
//        for i in 1...4 {
//            dataSource.append(UIImage(named: "Card_like_\(i)")!)
//        }
//        myKolodaView.insertCardAtIndexRange(position..<position + 4, animated: true)
        myKolodaView.resetCurrentCardIndex()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //        UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
        print("selected a card!")
    }
    
//    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
//        return true
//    }
//    
//    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
//        return false
//    }
//    
//    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
//        return true
//    }
    
//    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
//        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
//        animation?.springBounciness = frameAnimationSpringBounciness
//        animation?.springSpeed = frameAnimationSpringSpeed
//        return animation
//    }
}

extension SwipeController: KolodaViewDataSource {
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return userProfileImages.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
//        let containerView = UIView(frame: koloda.frame)
//        containerView.clipsToBounds = false
//        containerView.applyPlainShadow()
        
        let imageView = UIImageView(image: userProfileImages[Int(index)])
//        imageView.image =
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.applyPlainShadow()
        
//        containerView.addSubview(imageView)
        
        return imageView
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        
//        let customOverLayView = CustomOverlayView()
        let normalOverlay = OverlayView()
        return normalOverlay
    }
}
