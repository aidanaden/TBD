//
//  MainNavigationController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 12/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Firebase


class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isNavigationBarHidden = true
        self.view.backgroundColor = .white
        
        if isLoggedIn() {
            
            perform(#selector(showMainPageController), with: nil, afterDelay: 0.001)
            
        } else {
            perform(#selector(showLoginController), with: nil, afterDelay: 0.001)
        }
    }
    
    fileprivate func isLoggedIn() -> Bool {
        
        return UserDefaults.standard.bool(forKey: kLOGGEDIN)
    }
    
    func showLoginController() {
        let loginController = LoginController()
        self.present(loginController, animated: true, completion: nil)
    }
    
    func showMainPageController() {
        let mainPageController = MainPageController()
        let mainPageNavController = UINavigationController(rootViewController: mainPageController)
        mainPageNavController.navigationBar.isHidden = true
        mainPageNavController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.present(mainPageNavController, animated: true, completion: nil)
    }
}










