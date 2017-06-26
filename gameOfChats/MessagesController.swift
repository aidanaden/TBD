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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOut))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_message_icon"), style: .plain, target: self, action: #selector(createNewMessage))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: userCellId)
        
        checkIfUserIsLoggedIn()
        
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let userMessagesRef = firebase.child(kUSERMESSAGES).child(uid)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            let userRef = userMessagesRef.child(userId)
            
            userRef.observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                
                self.fetchMessageAndAttemptReload(messageId: messageId)
            })
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
                
                self.attemptReloadTable()
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
            
            if let doubledate1 = Double(message1.date!), let doubledate2 = Double(message2.date!) {
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
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            
            perform(#selector(logOut), with: nil, afterDelay: 0)
            
        } else {
            
            fetchUserNameAndSetUpNavBarTitle()
        }
    }
    
    func fetchUserNameAndSetUpNavBarTitle() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        firebase.child(kUSERS).child(uid).observe(.value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                let dictionary = snapshot.value as! [String: Any]
                let user = User()
                user.setValuesForKeys(dictionary)
                
                self.setupNavBarWithUser(user: user)
            }
        })
    }
    
    func setupNavBarWithUser(user: User) {
        
        // cleans up all data
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        
        if let profileImageURL = user.profileImageUrl {
            
            let profileUrl = URL(string: profileImageURL)
            let resource = ImageResource(downloadURL: profileUrl!)
            profileImageView.kf.setImage(with: resource)
        }
        
        containerView.addSubview(profileImageView)
        
        // constraints for image view
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLbl = UILabel()
        nameLbl.text = user.name
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLbl)
        
        nameLbl.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLbl.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLbl.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLbl.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        
        self.navigationItem.titleView = titleView
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func showChatController(user: User) {
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func logOut() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        
        let loginController = LoginVC()
        loginController.messagesController = self
        self.present(loginController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesDictionary.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
        firebase.child(kUSERS).child(chatPartnerId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                
                let user = User()
                user.id = chatPartnerId
                user.setValuesForKeys(dictionary)
                
                self.showChatController(user: user)
            }
        })
    }
}





