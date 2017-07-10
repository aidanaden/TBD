//
//  UserProfileController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 9/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase


class UserProfileController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        checkIfUserIsLoggedIn()
        SetUpNavBar()
    }
    
    var mainPageController: MainPageController?
    
    func SetUpNavBar() {
        
        let navigationItem = UINavigationItem()
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: mainPageController, action: #selector(mainPageController?.rightButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.darkGray
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 64))
        navBar.pushItem(navigationItem, animated: false)
        navBar.backgroundColor = UIColor.init(colorLiteralRed: 240, green: 240, blue: 240, alpha: 1)
        view.addSubview(navBar)
    }
    
    func checkIfUserIsLoggedIn() {
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            
            return

        } else {
            
            fetchUserNameAndSetUpProfile()
        }
    }
    
    func fetchUserNameAndSetUpProfile() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        firebase.child(kUSERS).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                let dictionary = snapshot.value as! [String: Any]
                let user = User()
                user.setValuesForKeys(dictionary)
                
                self.SetUpUIWithUser(user: user)
            }
        })
    }
    
    func SetUpUIWithUser(user: User) {
        
        let containerView = UIView(frame: CGRect(x: view.bounds.width / 2 - 100, y: view.bounds.height / 2 - 150, width: 200, height: 300))
        containerView.backgroundColor = UIColor.clear
        
        view.addSubview(containerView)
       
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 75
    
        guard let profileImageUrl = URL(string: user.profileImageUrl!) else { return }
        let resource = ImageResource(downloadURL: profileImageUrl)
        
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { (image, err, cacheType, url) in
            
            profileImageView.image = image
        }
        
        containerView.addSubview(profileImageView)
        
        _ = profileImageView.anchor(containerView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 150)
        profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true

        let nameTextView = UITextView()
        nameTextView.translatesAutoresizingMaskIntoConstraints = false
        nameTextView.isEditable = false
        nameTextView.text = user.name!
        
        let color = UIColor(white: 0.2, alpha: 1)
        let attributedText = NSMutableAttributedString(string: user.name!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightBold), NSForegroundColorAttributeName: color])
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let length = nameTextView.text.characters.count
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: length))
        
        nameTextView.attributedText = attributedText
        
        containerView.addSubview(nameTextView)
        
        _ = nameTextView.anchor(profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: containerView.bounds.width, heightConstant: 44)
        nameTextView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        let logOutButton = UIButton()
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        logOutButton.setTitle("Log Out", for: .normal)
        logOutButton.setTitleColor(UIColor.white, for: .normal)
        logOutButton.backgroundColor = UIColor.darkGray
        logOutButton.layer.cornerRadius = 25
        logOutButton.clipsToBounds = true
        logOutButton.dropShadow()
        logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        
        view.addSubview(logOutButton)
        
        _ = logOutButton.anchor(containerView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
        
        logOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    func logOut() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}











