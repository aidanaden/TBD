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
import Koloda
import pop

class SwipeController: UIViewController {
    
    let numberOfCards: Int = 5
    let frameAnimationSpringBounciness: CGFloat = 9
    let frameAnimationSpringSpeed: CGFloat = 16
    let kolodaCountOfVisibleCards = 2
    let kolodaAlphaValueSemiTransparent: CGFloat = 0.1
    
//    let myKolodaView: CustomKolodaView = {
//        let kolodaView = CustomKolodaView()
//        kolodaView.translatesAutoresizingMaskIntoConstraints = false
//        return kolodaView
//    }()
    
    let myKolodaView: KolodaView = {
        let kolodaView = KolodaView()
        kolodaView.translatesAutoresizingMaskIntoConstraints = false
        return kolodaView
    }()
    
    
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
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "btn_like_pressed"), for: .selected)
        return button
    }()

    
    var userProfileImages: [UIImage] = [#imageLiteral(resourceName: "nedstark")]
    
    func setupViews() {
       
//        userProfileImages.append(#imageLiteral(resourceName: "nedstark"))
        
        let navBar = UINavigationBar()
        
        navBar.barStyle = .default
        navBar.tintColor = .darkGray
        
        let navigationItem = UINavigationItem()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: mainPageController, action: #selector(mainPageController?.leftButtonAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Messages", style: .plain, target: mainPageController, action: #selector(mainPageController?.rightButtonAction))
        navigationItem.title = "Search"
        
        navBar.pushItem(navigationItem, animated: false)
        
        view.addSubview(navBar)
        
        _ = navBar.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.bounds.width, heightConstant: 64)
        
        likeButton.addTarget(self, action: #selector(handleRightSwiped), for: .touchUpInside)
        
        view.addSubview(myKolodaView)
        
        myKolodaView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        myKolodaView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        myKolodaView.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 25).isActive = true
        myKolodaView.widthAnchor.constraint(equalToConstant: view.bounds.width - 50).isActive = true
        
        view.addSubview(likeButton)
        
        _ = likeButton.anchor(nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 25, rightConstant: 80, widthConstant: 38, heightConstant: 34)
        
    }
    
    func handleRightSwiped() {
        myKolodaView.swipe(.right)
    }
    
    var mainPageController: MainPageController? {
        didSet {
            setupViews()
        }
    }
    
    var dataSource: [UIImage] = {
        
        var array = [UIImage]()
        for index in 0 ..< 5 {
            array.append(UIImage(named: "Card_like_\(index + 1)")!)
        }
//        for index in 0 ..< 5 {
//            array.append(UIImage(named: "Card_like_\(index + 1)")!)
//        }
        
        return array
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        downloadProfiles()
//        setupViews()
//
//        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
//        profileImageView.addGestureRecognizer(gesture)
        
//        myKolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
//        myKolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        myKolodaView.delegate = self
        myKolodaView.dataSource = self
//        myKolodaView.animator = BackgroundKolodaAnimator(koloda: myKolodaView)
        
        self.modalTransitionStyle = .flipHorizontal
        
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
//        profileImageView.kf.setImage(with: resource)
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { (image, err, cacheType, url) in
            
            self.userProfileImages.append(image!)
            print("DOWNLOADED PROFILE IMAGE!")
        }
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















