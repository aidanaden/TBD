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
//        navigationBarShouldNotExist = false
        datasource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    var mainNavController: MainNavigationController?
    
    func dismissToLogin() {
        
        self.dismiss(animated: true, completion: nil)
        mainNavController?.showLoginController()
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
        messagesVC.isNavigationBarHidden = true
        
        
        
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
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.barTintColor = .white
        navigationBar.tintColor = .darkGray
        
        let navigationItem = UINavigationItem(title: title)
        navigationItem.hidesBackButton = true
        
        if index == 0 {
            
            let rightBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
            navigationItem.rightBarButtonItem = rightBarButton
            
            navigationItem.leftBarButtonItem = nil
            
            navigationItem.rightBarButtonItem?.tintColor = .darkGray
            
        } else if index == 1 {
            
            let leftButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: nil)
            navigationItem.leftBarButtonItem = leftButtonItem
            
            let rightButtonItem = UIBarButtonItem(title: "Messages", style: .plain, target: self, action: nil)
            navigationItem.rightBarButtonItem = rightButtonItem
            
            navigationItem.leftBarButtonItem?.tintColor = UIColor.darkGray
            navigationItem.rightBarButtonItem?.tintColor = UIColor.darkGray
            
        } else if index == 2 {
            
            let leftButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
            
            navigationItem.leftBarButtonItem = leftButtonItem
//            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_message_icon"), style: .plain, target: self, action: nil)
//            
//            navigationItem.rightBarButtonItem?.tintColor = .darkGray
            navigationItem.leftBarButtonItem?.tintColor = .darkGray
        }
        
        navigationBar.pushItem(navigationItem, animated: false)
        
        return navigationBar
    }
    
}






