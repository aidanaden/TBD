//
//  SearchController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 12/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class SwipeController: UIViewController {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = #imageLiteral(resourceName: "nedstark")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 0.5
        return imageView
    }()
    
    func setupViews() {
        
        view.addSubview(profileImageView)
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func setupNavBar() {
        
        let navBar = UINavigationBar()
        navBar.barStyle = .default
        
        view.addSubview(navBar)
        
        _ = navBar.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.bounds.width, heightConstant: 64)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        setupViews()
        setupNavBar()
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        profileImageView.addGestureRecognizer(gesture)
        
        downloadProfiles()
    }
    
    var Users = [User]()
    
    func downloadProfiles() {
        
        firebase.child(kUSERS).observe(.value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                let childrenCount = Int(snapshot.childrenCount)
                
                for snap in snapshot.children {
                    
                    let userDictionary = (snap as! FIRDataSnapshot).value as! [String: Any]
                    
                    let user = User()
                    user.id = (snap as! FIRDataSnapshot).key
                    
                    user.setValuesForKeys(userDictionary)
                    
                    // add if statement to prevent current user from seeing himself
                    print("appended user")
                    self.Users.append(user)
                    self.downloadProfileImages(user: user)
                    
                }
            }
        })
    }
    
    func downloadProfileImages(user: User) {
        
        guard let strUrl = user.profileImageUrl, let Url = URL(string: strUrl) else { return }
        let resource = ImageResource(downloadURL: Url)
        profileImageView.kf.setImage(with: resource)
    }
    
    var index = 1
    
    func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: view)
        let imageView = gestureRecognizer.view as! UIImageView
        
        imageView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let xFromCenter = imageView.center.x - self.view.bounds.width / 2
        let scale = min(abs(100 / xFromCenter), 1)
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        var rotationAndStretch = rotation.scaledBy(x: scale, y: scale)
        
        imageView.transform = rotationAndStretch
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            if imageView.center.x < 100 {
                
                imageView.transform = CGAffineTransform(rotationAngle: 0)
                
            } else if imageView.center.x > self.view.bounds.width - 100 {
                
                imageView.transform = CGAffineTransform(rotationAngle: 0)
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            rotationAndStretch = rotation.scaledBy(x: 1, y: 1)
            imageView.transform = rotationAndStretch
            imageView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            
            if index < Users.count {
                
                let user = Users[index]
    
                downloadProfileImages(user: user)
                index += 1
            }
            
            if index >= Users.count {
                index = 0
            }
            
        }
    }
}
















