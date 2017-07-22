//
//  NewMessageController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 22/6/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class NewMessageController: UITableViewController {

    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: userCellId)
        
        fetchUsers()
    }
    
    func fetchUsers() {
        
        self.users.removeAll()
        
        firebase.child(kUSERS).observe(.childAdded, with: { (snapshot) in
            
            let userDictionary = snapshot.value as! [String : Any]
            let user = User()
            
            user.id = snapshot.key
            // if u use this setter, app may crash if User class properties do not match exactly with firebase dictionary properties
            
            user.setValuesForKeys(userDictionary)
            
            if user.id! != Auth.auth().currentUser!.uid {
                
                self.users.append(user)
            }
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
            
            
        }, withCancel: nil)
        
        firebase.child(kUSERS).observe(.value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                for user in (snapshot.value as! NSDictionary).allValues as NSArray {
                    
                    print(user)
                    print(snapshot.key)
                }
            }
        })
    }

    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name!
        cell.detailTextLabel?.text = user.email!
        
        if let profileImageUrl = user.profileImageUrl {
            
            let profileImageURL = URL(string: profileImageUrl)
            let resource = ImageResource(downloadURL: profileImageURL!)
            
            cell.profileImageView.kf.setImage(with: resource)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = self.users[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        dismiss(animated: true, completion: {
            
            self.messagesController?.showChatController(user: user)
            print("dismiss completed")
        })
    }
}











