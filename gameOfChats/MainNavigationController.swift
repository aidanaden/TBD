//
//  MainNavigationController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 12/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Firebase
import SLPagingViewSwift_Swift3


class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isNavigationBarHidden = true
        self.view.backgroundColor = .white
        
        if isLoggedIn() {
            
            perform(#selector(showSLPagingController), with: nil, afterDelay: 0.1)
            
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
        mainPageController.mainNavController = self
        mainPageNavController.navigationBar.isHidden = true
        mainPageNavController.navigationBar.setBackgroundImage(UIImage.imageWithColor(color: .white), for: .default) // set nav bar background color for shadow to appear
        mainPageNavController.navigationBar.shadowImage = UIImage.imageWithColor(color: UIColor.init(white: 0.9, alpha: 0.5))
        mainPageNavController.navigationBar.barTintColor = .white
        mainPageNavController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.present(mainPageNavController, animated: true, completion: nil)
    }
    
    func showSLPagingController() {
        
        let profileVC = UserProfileController()
//        profileVC.mainPageController = self
        
        let swipeVC = SwipeController()
//        swipeVC.mainPageController = self
        
        let messagesController = MessagesController()
//        messagesController.mainPageController = self
        let messagesVC = UINavigationController(rootViewController: messagesController)
//        messagesVC.isNavigationBarHidden = true
        
        var img1 = #imageLiteral(resourceName: "chat_full")
        img1 = img1.withRenderingMode(.alwaysTemplate)
        
        var img2 = #imageLiteral(resourceName: "gear")
        img2 = img2.withRenderingMode(.alwaysTemplate)
        
        var img3 = #imageLiteral(resourceName: "rchat")
        img3 = img3.withRenderingMode(.alwaysTemplate)
        
        let controllers = [profileVC, swipeVC, messagesController]
        let items = [UIImageView(image: img1), UIImageView(image: img2), UIImageView(image: img3)]
        
        let pagingController = SLPagingViewSwift(items: items, controllers: controllers, showPageControl: false)
        pagingController.currentPageControlColor = .white

        pagingController.pagingViewMoving = ({ subviews in
            if let imageViews = subviews as? [UIImageView] {
                for imgView in imageViews {
                    var c = gray
                    let originX = Double(imgView.frame.origin.x)
                    
                    if (originX > 45 && originX < 145) {
                        c = self.gradient(originX, topX: 46, bottomX: 144, initC: orange, goal: gray)
                    }
                    else if (originX > 145 && originX < 245) {
                        c = self.gradient(originX, topX: 146, bottomX: 244, initC: gray, goal: orange)
                    }
                    else if(originX == 145){
                        c = orange
                    }
                    imgView.tintColor = c
                }
            }
        })
        
        let navPagingController = UINavigationController(rootViewController: pagingController)
        self.present(navPagingController, animated: true, completion: nil)
    }
    
    func gradient(_ percent: Double, topX: Double, bottomX: Double, initC: UIColor, goal: UIColor) -> UIColor{
        let t = (percent - bottomX) / (topX - bottomX)
        
        let cgInit = initC.cgColor.components
        let cgGoal = goal.cgColor.components
        
        let r_last = ((cgGoal?[0])! - (cgInit?[0])!)
        let g_last = ((cgGoal?[1])! - (cgInit?[1])!)
        let b_last = ((cgGoal?[2])! - (cgInit?[2])!)
        
        let r = (cgInit?[0])! + (CGFloat(t)) * r_last
        let g = (cgInit?[1])! + CGFloat(t) * g_last
        let b = (cgInit?[2])! + CGFloat(t) * b_last
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}










