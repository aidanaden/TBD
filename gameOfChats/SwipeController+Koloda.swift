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
        
        print(index)
        
        let containerView = UIView(frame: koloda.frame)
        containerView.clipsToBounds = false
        containerView.applyPlainShadow()
        
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = Users[index].name!
        textView.backgroundColor = .clear
        
        let attributedText = NSMutableAttributedString(string: textView.text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium), NSForegroundColorAttributeName: UIColor.white])
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let length = textView.text.characters.count
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: length))
        
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize.zero
        shadow.shadowBlurRadius = 5
        shadow.shadowColor = UIColor.black
        
        attributedText.addAttribute(NSShadowAttributeName, value: shadow, range: NSRange(location: 0, length: length))
        
        textView.attributedText = attributedText
        
        let imageView = UIImageView(image: userProfileImages[Int(index)])
//        imageView.image =
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
//        imageView.applyPlainShadow()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.addSubview(textView)
        
        _ = textView.anchor(nil, left: imageView.leftAnchor, bottom: imageView.bottomAnchor, right: imageView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 80)
        
        containerView.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
//        return imageView
        return containerView
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        
        let customOverLayView = CustomOverlayView()
//        let normalOverlay = OverlayView()
        return customOverLayView
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.3
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    
}






