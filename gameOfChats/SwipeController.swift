//
//  SwipeController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 3/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import EZSwipeController // if using Cocoapods

class SwipeController: EZSwipeController, EZSwipeControllerDataSource {
    
    lazy var pageControl: UIPageControl = {
        
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = UIColor(red: 247/255, green: 154/255, blue: 27/255, alpha: 1)
        pc.pageIndicatorTintColor = .lightGray
        
        return pc
    }()
    
    let skipButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor(red: 247/255, green: 154/255, blue: 27/255, alpha: 1), for: .normal)
        btn.setTitle("Skip", for: .normal)
        return btn
    }()
    
    let nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Next", for: .normal)
        btn.setTitleColor(UIColor(red: 247/255, green: 154/255, blue: 27/255, alpha: 1), for: .normal)
        return btn
    }()
    
    var pageControlBottomAnchor: NSLayoutConstraint?
    var skipButtonTopAnchor: NSLayoutConstraint?
    var nextButtonTopAnchor: NSLayoutConstraint?
    
    override func setupView() {
        datasource = self
        //        navigationBarShouldBeOnBottom = true
        navigationBarShouldNotExist = true
                cancelStandardButtonEvents = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
        view.backgroundColor = UIColor.white
        
        self.view.addSubview(pageControl)
        self.view.addSubview(skipButton)
        self.view.addSubview(nextButton)
        
        pageControlBottomAnchor = pageControl.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)?[1] // returns second anchor which is the bottom anchor
        
        skipButtonTopAnchor = skipButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 15, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 50)?.first
        
        nextButtonTopAnchor = nextButton.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 5, widthConstant: 60, heightConstant: 50)?.first
    }
    
    func viewControllerData() -> [UIViewController] {
        
        let firstVC = PageController()
        //        redVC.view.backgroundColor = .red
        
        var sImage = UIImage(named: "nedstark")!
        sImage = scaleTo(image: sImage, w: 80, h: 100)
        
        
        let secondVC = UIViewController()
        secondVC.view.backgroundColor = .white
        
        let loginVC = LoginVC()
        
        let viewArray = [firstVC, secondVC, loginVC]
        pageControl.numberOfPages = viewArray.count
        
        return viewArray
    }
    
    
    
    //    func navigationBarDataForPageIndex(_ index: Int) -> UINavigationBar {
    //
    //        var title = ""
    //        if index == 0 {
    //            title = "Page 1"
    //        } else if index == 1 {
    //            title = "Page 2"
    //        } else if index == 2 {
    //            title = "Page 3"
    //        }
    //
    //        let navigationBar = UINavigationBar()
    //        navigationBar.barStyle = UIBarStyle.default
    //        navigationBar.alpha = 0
    //        navigationBar.backgroundColor = nil
    //
    //        let navigationItem = UINavigationItem(title: title)
    //        navigationItem.hidesBackButton = true
    //
    //        if index == 0 {
    //
    //            let rightButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: nil)
    //            rightButtonItem.tintColor = UIColor.blue
    //
    //            navigationItem.leftBarButtonItem = nil
    //            navigationItem.rightBarButtonItem = rightButtonItem
    //        } else if index == 1 {
    ////            var cImage = UIImage(named: "page2")!
    ////            cImage = scaleTo(image: cImage, w: 22, h: 22)
    //            let leftButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: nil)
    //            leftButtonItem.tintColor = UIColor.red
    //
    ////            var bImage = UIImage(named: "nedstark")!
    ////            bImage = scaleTo(image: bImage, w: 22, h: 22)
    //            let rightButtonItem = UIBarButtonItem(title: "YO", style: .plain, target: self, action: nil)
    //            rightButtonItem.tintColor = UIColor.green
    //
    //            navigationItem.leftBarButtonItem = leftButtonItem
    //            navigationItem.rightBarButtonItem = rightButtonItem
    //        } else if index == 2 {
    ////            var sImage = UIImage(named: "page3")!
    ////            sImage = scaleTo(image: sImage, w: 22, h: 22)
    ////            let leftButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nedstark"), style: .plain, target: self, action: nil)
    ////            leftButtonItem.tintColor = UIColor.blue
    //
    //            navigationItem.leftBarButtonItem = nil
    //            navigationItem.rightBarButtonItem = nil
    //        }
    //
    //        navigationBar.pushItem(navigationItem, animated: false)
    //        return navigationBar
    //    }
    
    
    func changedToPageIndex(_ index: Int) {
        
        pageControl.currentPage = index
        
        if index == pageControl.numberOfPages - 1 {
            
            pageControlBottomAnchor?.constant = 100
            nextButtonTopAnchor?.constant = -100
            skipButtonTopAnchor?.constant = -100
            
        } else {
            
            pageControlBottomAnchor?.constant = 0
            nextButtonTopAnchor?.constant = 15
            skipButtonTopAnchor?.constant = 15
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded() // animate constraint changes
            
        }, completion: nil)
    }
    
    func moveToEnd() {
        self.moveToPage(2, animated: true)
    }
    
    func alert(title: String?, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

private func scaleTo(image: UIImage, w: CGFloat, h: CGFloat) -> UIImage {
    let newSize = CGSize(width: w, height: h)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
}

