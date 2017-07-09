//
//  MainPageController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 9/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import EZSwipeController


class MainPageController: EZSwipeController {
    
    override func setupView() {
        super.setupView()
        navigationBarShouldNotExist = true
        datasource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
    }
}

extension MainPageController: EZSwipeControllerDataSource {
    
    func viewControllerData() -> [UIViewController] {
        let profileVC = UserProfileController()
        
        let blueVC = UIViewController()
        blueVC.view.backgroundColor = UIColor.blue
        
        let messagesVC = UINavigationController(rootViewController: MessagesController())
        
        return [profileVC, blueVC, messagesVC]
    }
    
    func indexOfStartingPage() -> Int {
        return 1
    }
    
}






