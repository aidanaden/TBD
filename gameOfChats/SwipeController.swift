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
    
//    let numberOfCards: Int = 5
//    let frameAnimationSpringBounciness: CGFloat = 9
//    let frameAnimationSpringSpeed: CGFloat = 16
//    let kolodaCountOfVisibleCards = 2
//    let kolodaAlphaValueSemiTransparent: CGFloat = 0.1
    
//    let myKolodaView: CustomKolodaView = {
//        let kolodaView = CustomKolodaView()
//        kolodaView.translatesAutoresizingMaskIntoConstraints = false
//        return kolodaView
//    }()
    
    
    let containerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    

    let myKolodaView: CustomKolodaView = {
        let kolodaView = CustomKolodaView()
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
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    lazy var dislikeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFit
        return button
    }()

    
//    var userProfileImages: [UIImage] = [#imageLiteral(resourceName: "nedstark")]
    var userProfileImages = [UIImage]()
    
    func setupViews() {
       
//        userProfileImages.append(#imageLiteral(resourceName: "nedstark"))
        
//        let navBar = UINavigationBar()
//        
//        navBar.barStyle = .default
//        navBar.tintColor = .darkGray
//        
//        let navigationItem = UINavigationItem()
//        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: mainPageController, action: #selector(mainPageController?.leftButtonAction))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Messages", style: .plain, target: mainPageController, action: #selector(mainPageController?.rightButtonAction))
//        navigationItem.title = "Search"
//        
//        navBar.pushItem(navigationItem, animated: false)
//        
//        view.addSubview(navBar)
//        
//        _ = navBar.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.bounds.width, heightConstant: 64)
        
        myKolodaView.countOfVisibleCards = 2
        
        view.addSubview(containerView)
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -65).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 600).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: view.bounds.width - 50).isActive = true
        
        
        containerView.addSubview(myKolodaView)
        
        myKolodaView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        myKolodaView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70).isActive = true
        myKolodaView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        myKolodaView.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: 0).isActive = true
        
        likeButton.addTarget(self, action: #selector(handleRightSwiped), for: .touchUpInside)
        dislikeButton.addTarget(self, action: #selector(handleLeftSwiped), for: .touchUpInside)
        
        containerView.addSubview(likeButton)
        containerView.addSubview(dislikeButton)
        
        _ = likeButton.anchor(nil, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 50, widthConstant: 34, heightConstant: 38)
        
        _ = dislikeButton.anchor(nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 50, bottomConstant: 0, rightConstant: 0, widthConstant: 34, heightConstant: 38)
        
    }
    
    func handleLeftSwiped() {
        myKolodaView.swipe(.left)
    }
    
    func handleRightSwiped() {
        myKolodaView.swipe(.right)
    }
    
    var mainPageController: MainPageController? {
        didSet {
            setupViews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        downloadProfiles()
        
        dislikeButton.setImage(#imageLiteral(resourceName: "btn_skip_normal"), for: .normal)
        dislikeButton.setImage(#imageLiteral(resourceName: "btn_skip_pressed"), for: .highlighted)
        
        likeButton.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)
        likeButton.setImage(#imageLiteral(resourceName: "btn_like_pressed"), for: .highlighted)
//        setupViews()

        
//        myKolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
//        myKolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        
        myKolodaView.delegate = self
        myKolodaView.dataSource = self
        
//        myKolodaView.animator = BackgroundKolodaAnimator(koloda: myKolodaView)
        
        self.modalTransitionStyle = .flipHorizontal
        
        
//        view.addSubview(likeButton)
//        view.addSubview(dislikeButton)
//        
//        likeButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 25).isActive = true
//        likeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 50).isActive = true
//        likeButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
//        likeButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        
//        dislikeButton.topAnchor.constraint(equalTo: myKolodaView.bottomAnchor, constant: -25).isActive = true
    
    }
    
    var Users = [User]()
    
    func downloadProfiles() {
        
        firebase.child(kUSERS).observe(.value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                let childrenCount = Int(snapshot.childrenCount)
                
                for snap in snapshot.children {
                    
                    let userDictionary = (snap as! DataSnapshot).value as! [String: Any]
                    
                    let user = User()
                    user.id = (snap as! DataSnapshot).key
                    
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
            self.myKolodaView.reloadData()
        }
    }
    
    func SwipedRight(user: User) {
        
        guard let selfId = Auth.auth().currentUser?.uid, let otherUserId = user.id else { return }
        
        let myValues = [otherUserId: 1]
        let mylikesRef = firebase.child(kMATCHES).child(selfId).child(kLIKES)
        
        mylikesRef.updateChildValues(myValues)
        
        let otherValues = [selfId: 1]
        let otherLikesRef = firebase.child(kMATCHES).child(otherUserId).child(kLIKEDBY)
        
        otherLikesRef.updateChildValues(otherValues)
        
    }
    
}















