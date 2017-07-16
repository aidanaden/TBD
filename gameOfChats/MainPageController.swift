//
//  MainPageController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 9/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import EZSwipeController
import Firebase

class MainPageController: EZSwipeController {
    
    
    override func setupView() {
        super.setupView()
        navigationBarShouldNotExist = true
        datasource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = true
    }
    
}


extension MainPageController: EZSwipeControllerDataSource {
    
    func viewControllerData() -> [UIViewController] {
        
        let profileVC = UserProfileController()
        profileVC.mainPageController = self
        
        let swipeVC = SwipeController()
        swipeVC.mainPageController = self
        
        let messagesController = MessagesController()
        messagesController.mainPageController = self
        let messagesVC = UINavigationController(rootViewController: messagesController)
        
        //        let messagesVC = MessagesController()
        //        messagesVC.navigationBar.isHidden = true
        
       
            
        return [profileVC, swipeVC, messagesVC]
        
    }
    
    
    func indexOfStartingPage() -> Int {
        return 1
    }
    
    func navigationBarDataForPageIndex(_ index: Int) -> UINavigationBar {
        
        var title = ""
        if index == 0 {
            title = "Profile"
        } else if index == 1 {
            title = "Search"
        } else if index == 2 {
            title = "Messages"
        }
        
        let navigationBar = UINavigationBar()
        navigationBar.barStyle = .default
        
        let navigationItem = UINavigationItem(title: title)
        navigationItem.hidesBackButton = true
        
        if index == 0 {
            
            let rightBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
            navigationItem.rightBarButtonItem = rightBarButton
            
            navigationItem.leftBarButtonItem = nil
            
        } else if index == 1 {
            
            let leftButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: nil)
            navigationItem.leftBarButtonItem = leftButtonItem
            
            let rightButtonItem = UIBarButtonItem(title: "Messages", style: .plain, target: self, action: nil)
            navigationItem.rightBarButtonItem = rightButtonItem
            
            
        } else if index == 2 {
            
            let leftButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
            
            navigationItem.leftBarButtonItem = leftButtonItem
            navigationItem.rightBarButtonItem = nil
        }
        
        navigationBar.pushItem(navigationItem, animated: false)
        
        return navigationBar
    }
}






