//
//  ViewController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 21/6/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class MessagesController: UITableViewController {
    
    var mainPageController: MainPageController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.white
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: mainPageController, action: #selector(mainPageController?.leftButtonAction))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_message_icon"), style: .plain, target: self, action: #selector(createNewMessage))
//
//        navigationItem.leftBarButtonItem?.tintColor = UIColor.darkGray
//        navigationItem.rightBarButtonItem?.tintColor = UIColor.darkGray
//        
//        navigationItem.title = "Messages"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: userCellId)
        tableView.separatorColor = UIColor.init(white: 0.9, alpha: 1)
        tableView.tableFooterView = UIView()
        
        checkIfUserIsLoggedIn()
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        // cleans up all data
        messages.removeAll()
        messagesDictionary.removeAll()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        guard let selectedRow = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selectedRow, animated: false)
    }

    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userMessagesRef = firebase.child(kUSERMESSAGES).child(uid)
        
//        userMessagesRef.observe(.childAdded, with: { (snapshot) in
//            
//            let userId = snapshot.key
//            let userRef = userMessagesRef.child(userId)
//            
//            userRef.observe(.childAdded, with: { (snapshot) in
//                
//                let messageId = snapshot.key
//                
//                self.fetchMessageAndAttemptReload(messageId: messageId)
//            })
//        })
        
        userMessagesRef.observe(.value, with: { (snapshot) in
            
            let children = Int(snapshot.childrenCount)
            
            if snapshot.exists() {
                
                for snap in snapshot.children {
                    
                    let userId = (snap as! DataSnapshot).key
                    let userRef = userMessagesRef.child(userId)
                    
                    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        for snap in snapshot.children {
                            
                            let messageId = (snap as! DataSnapshot).key
                            self.fetchMessageAndAttemptReload(messageId: messageId)
                        }
                    })
                }
            }
        })
        
        userMessagesRef.observe(.childRemoved, with: { (snapshot) in
            
            if snapshot.exists() {
                
                self.messagesDictionary.removeValue(forKey: snapshot.key)
                self.attemptReloadTable()
            }
        })
    }
    
    private func fetchMessageAndAttemptReload(messageId: String) {
        
        let messagesRef = firebase.child(kMESSAGES).child(messageId)
        
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    
                    self.messagesDictionary[chatPartnerId] = message
                }
                
//                self.attemptReloadTable()
                self.handleReloadTable()
            }
        })
    }
    
    private func attemptReloadTable() {
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    func handleReloadTable() {
        
        self.messages = Array(self.messagesDictionary.values) // stores latest message of each conversation
        
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            if let doubledate1 = message1.date, let doubledate2 = message2.date {
                // sort messages by descending date order --> latest to earliest/ newer to older messages
                return doubledate1 > doubledate2
            }
            return true
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func createNewMessage() {
        
        let newMessageVC = NewMessageController()
        newMessageVC.messagesController = self
        let navVC = UINavigationController(rootViewController: newMessageVC)
        
        present(navVC, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        
        if Auth.auth().currentUser?.uid == nil {
            
            perform(#selector(logOut), with: nil, afterDelay: 0)
            
        } else {
            
            observeMessagesAndMatches()
        }
    }
    
    var matchedUsers = [User]()
    var likedUsersId = [String]()
    var likedByUsersId = [String]()
    var matchedUsersId = [String]()
    
    func observeMessagesAndMatches() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        observeUserMessages()
        
//        firebase.child(kUSERS).child(uid).observe(.value, with: { (snapshot) in
//            
//            if snapshot.exists() {
//                
//                let dictionary = snapshot.value as! [String: Any]
//                let user = User()
//                user.setValuesForKeys(dictionary)
//                
//                self.setupNavBarWithUser(user: user)
//            }
//        })
        
        firebase.child(kMATCHES).child(uid).child(kLIKES).observe(.value, with: { (snapshot) in
            
            if snapshot.exists() {
               
                let likesChildrenCount = Int(snapshot.childrenCount)
                
                for snap in snapshot.children {
                    
                    let userId = (snap as! DataSnapshot).key
                    self.likedUsersId.append(userId)
                }
                
                firebase.child(kMATCHES).child(uid).child(kLIKEDBY).observe(.value, with: { (snapshot) in
                    
                    if snapshot.exists() {
                        
                        let likedChildrenCount = Int(snapshot.childrenCount)
                        
                        for snap in snapshot.children {
                            
                            let userId = (snap as! DataSnapshot).key
                            self.likedByUsersId.append(userId)
                        }
                        
                        if self.likedUsersId.count > self.likedByUsersId.count {
                           
                            for likedByUserId in self.likedByUsersId {
                                
                                if self.likedUsersId.contains(likedByUserId) {
                                    
                                    self.matchedUsersId.append(likedByUserId)
                                }
                            }
                            
                        } else {
                            
                            for likedUserId in self.likedUsersId {
                                
                                if self.likedByUsersId.contains(likedUserId) {
                                    
                                    self.matchedUsersId.append(likedUserId)
                                }
                            }
                        }
                        
                        print("we matched with \(self.matchedUsersId)")
                        
                        for matchedUserId in self.matchedUsersId {
                            
                            if self.messagesDictionary[matchedUserId] == nil {
                                
                                print("does not contain message: create chat controller")
                                self.getUserFromFirebase(userId: matchedUserId, completion: { (user) in
                                    
                                    self.showChatControllerForMatchedUser(user: user)
                                })
                            }
                        }
                    }
                })
            }
        })
    }
    
    
    func setupNavBarWithUser(user: User) {
        
//        DispatchQueue.main.async {
//
//            let titleView = UIView()
//            titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
//            
//            let containerView = UIView()
//            containerView.translatesAutoresizingMaskIntoConstraints = false
//            titleView.addSubview(containerView)
//            
//            containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
//            containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
//            
//            let profileImageView = UIImageView()
//            profileImageView.translatesAutoresizingMaskIntoConstraints = false
//            profileImageView.contentMode = .scaleAspectFill
//            profileImageView.layer.cornerRadius = 15
//            profileImageView.layer.masksToBounds = true
//            
//            if let profileImageURL = user.profileImageUrl {
//                
//                let profileUrl = URL(string: profileImageURL)
//                let resource = ImageResource(downloadURL: profileUrl!)
//                profileImageView.kf.setImage(with: resource)
//            }
//            
//            containerView.addSubview(profileImageView)
//            
//            // constraints for image view
//            profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//            profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//            profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
//            profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
//            
//            let nameLbl = UILabel()
//            nameLbl.text = user.name
//            nameLbl.translatesAutoresizingMaskIntoConstraints = false
//            
//            containerView.addSubview(nameLbl)
//            
//            nameLbl.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
//            nameLbl.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
//            nameLbl.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//            nameLbl.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
//            
//            
//            self.navigationItem.titleView = titleView
//        }
    }
    
    func showChatControllerForMatchedUser(user: User) {
        
        let jsqMessagesController = JSQMessagesController()
        jsqMessagesController.user = user
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .darkGray
        
        jsqMessagesController.matched = true
        
        self.parent!.navigationController?.pushViewController(jsqMessagesController, animated: true)
    }
    
    func showChatController(user: User) {

        let jsqMessagesController = JSQMessagesController()
        jsqMessagesController.user = user
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .darkGray
        
//        self.parent!.navigationController!.pushViewController(jsqMessagesController, animated: true)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//            self.parent!.navigationController!.pushViewController(jsqMessagesController, animated: true)
//
//        })
        
        jsqMessagesController.observeMessages { (completed) in
            
            if completed {
                self.parent!.navigationController!.pushViewController(jsqMessagesController, animated: true)
            }
        }
        
//        perform(#selector(handlePush(viewController: jsqMessagesController)), with: nil, afterDelay: 0.1)
//        navigationController?.pushViewController(jsqMessagesController, animated: true)
        //        navigationController?.navigationBar.isHidden = false
    }
    
    func handlePush(viewController: JSQMessagesController) {
        self.parent!.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func logOut() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        
//        let loginController = LoginVC()
//        loginController.messagesController = self
//        let loginViewController = viewController()
//        self.present(loginController, animated: true, completion: nil)
        
        firebase.removeAllObservers()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesDictionary.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 10)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
//        firebase.child(kUSERS).child(chatPartnerId).observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            if let dictionary = snapshot.value as? [String: Any] {
//                
//                let user = User()
//                user.id = chatPartnerId
//                user.setValuesForKeys(dictionary)
//                
//                self.showChatController(user: user)
//            }
//        })
        getUserFromFirebase(userId: chatPartnerId) { (user) in
            
            self.showChatController(user: user)
        }
    }
    
    func getUserFromFirebase(userId: String, completion: @escaping (_ user: User) -> Void) {
        
        firebase.child(kUSERS).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                
                let user = User()
                user.id = userId
                user.setValuesForKeys(dictionary)
                
                completion(user)
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let currentId = Auth.auth().currentUser?.uid else { return }
        
        let message = messages[indexPath.row]
        
        guard let chatPartner = message.chatPartnerId() else { return }
        
        firebase.child(kUSERMESSAGES).child(currentId).child(chatPartner).removeValue { (error, ref) in
            
            if error != nil {
                print("AIDAN: failed to delete messages")
                return
            }
            
            self.messagesDictionary.removeValue(forKey: chatPartner)
            self.attemptReloadTable()
        }
    }
    
}





