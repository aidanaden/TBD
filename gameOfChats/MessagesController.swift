//
//  ViewController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 21/6/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOut))
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(logOut), with: nil, afterDelay: 0)
        } 
    }

    func logOut() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        
        let loginController = LoginVC()
        self.present(loginController, animated: true, completion: nil)
    }

}

