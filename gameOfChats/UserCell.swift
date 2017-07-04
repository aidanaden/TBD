//
//  UserCell.swift
//  gameOfChats
//
//  Created by Aidan Aden on 22/6/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            
            setupNameAndProfileImage()
            
            self.detailTextLabel?.text = self.message?.text
            
            if let seconds = self.message?.date {
                
                let doubleSeconds = Double(seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                let convertedTime = NSDate(timeIntervalSince1970: doubleSeconds)
                self.timeLbl.text = dateFormatter.string(from: convertedTime as Date)
            }
            
        }
    }
    
    private func setupNameAndProfileImage() {
        
        
        if let id = message?.chatPartnerId() {
            
            firebase.child(kUSERS).child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.exists() {
                    
                    if let dictionary = snapshot.value as? [String: Any] {
                        
                        self.textLabel?.text = dictionary[kNAME] as? String
                        
                        if let url = dictionary[kPROFILEIMAGEURL] as? String, let profileURL = URL(string: url) {
                            
                            let resource = ImageResource(downloadURL: profileURL)
                            self.profileImageView.kf.setImage(with: resource)
                        }
                    }
                }
            })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    let timeLbl: UILabel = {
        
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        // profile image view constraints
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        addSubview(timeLbl)
        
        // time label constraints
        timeLbl.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLbl.topAnchor.constraint(equalTo: self.topAnchor, constant: 23).isActive = true
        timeLbl.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLbl.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}



