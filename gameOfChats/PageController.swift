//
//  PageController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 3/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit


class PageController: UIViewController {
    
    var titleName: String = "PageVC"
    
    let color = UIColor(white: 0.2, alpha: 1)
    
    let imageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "page1")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.text = "LOLOLOLOLOLSOADLOSDAODLA"
        tv.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        
        return tv
    }()
    
    let lineSeperatorView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        let attributedText = NSMutableAttributedString(string: "PAGE 1 TITLE XD", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium), NSForegroundColorAttributeName: color])
        
        attributedText.append(NSMutableAttributedString(string: "\n\nPage1 MESSAGES XD", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium), NSForegroundColorAttributeName: color]))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let length = textView.text.characters.count
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: length))
        
        textView.attributedText = attributedText
        
        view.addSubview(imageView)
        view.addSubview(textView)
        view.addSubview(lineSeperatorView)
        
        imageView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: self.textView.topAnchor, right: view.rightAnchor)
        
        textView.anchorWithConstantsToTop(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 16)
        textView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        
        lineSeperatorView.anchorToTop(nil, left: view.leftAnchor, bottom: textView.topAnchor, right: view.rightAnchor)
        lineSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
}





