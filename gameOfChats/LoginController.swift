//
//  ViewController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 28/6/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var loginCell: LoginCell?
    var messagesController: MessagesController?
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    let pages: [Page] = {
       
        let firstPage = Page(imageName: "page1", title: "THIS IS PAGE 1", message: "HAHEHEHHEEHEEHYSHD THIS IS A MESSAGE FOR PAGE 1")
        let secondPage = Page(imageName: "page2", title: "THIS IS PAGE 2", message: "HAHDUSHDUHUHSUDHD THIS IS A TEST MESSAGE FOR PAGE 2 GUSY")
        let thirdPage = Page(imageName: "page3", title: "THIS IS PAGE 3", message: "HASHUSHDUNDJFDNFUDNUFH THIS IS A TEST TEST TEST MESSAGE FOR PAGE 3 YEABOIII")
        
        return [firstPage, secondPage, thirdPage]
    }()
    
    lazy var pageControl: UIPageControl = {
        
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = UIColor(red: 247/255, green: 154/255, blue: 27/255, alpha: 1)
        pc.pageIndicatorTintColor = .lightGray
        pc.numberOfPages = self.pages.count + 1
        
        return pc
    }()
    
    lazy var skipButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor(red: 247/255, green: 154/255, blue: 27/255, alpha: 1), for: .normal)
        btn.setTitle("Skip", for: .normal)
        btn.addTarget(self, action: #selector(skipPages), for: .touchUpInside)
        return btn
    }()
    
    func skipPages() {
        
        pageControl.currentPage = pages.count - 1
        nextPage()
    }
    
    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Next", for: .normal)
        btn.setTitleColor(UIColor(red: 247/255, green: 154/255, blue: 27/255, alpha: 1), for: .normal)
        btn.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return btn
    }()
    
    func nextPage() {
        
        if pageControl.currentPage == pages.count {
            return
        }
        
        if pageControl.currentPage == pages.count - 1{
            moveControlsOffScreen()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.view.layoutIfNeeded() // animate constraint changes
                
            }, completion: nil)
        }
        
        let indexPath = IndexPath(item: pageControl.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage += 1
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    var pageControlBottomAnchor: NSLayoutConstraint?
    var skipButtonTopAnchor: NSLayoutConstraint?
    var nextButtonTopAnchor: NSLayoutConstraint?
    
    let cellId = "CellId"
    let loginCellId = "LoginCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeKeyboardNotifications()
        
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        
        _ = collectionView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        pageControlBottomAnchor = pageControl.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)?[1] // returns second anchor which is the bottom anchor
        
        skipButtonTopAnchor = skipButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 15, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 50)?.first
        
        nextButtonTopAnchor = nextButton.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 5, widthConstant: 60, heightConstant: 50)?.first
        
        registerCells()
    }
    
    
    func observeKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardShow() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: -65, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)

    }
    
    func keyboardHide() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageNumber = Int(targetContentOffset.pointee.x / self.view.frame.width)
        
        pageControl.currentPage = pageNumber
        
        if pageNumber == pages.count {
            
            moveControlsOffScreen()
            
        } else {
            
            pageControlBottomAnchor?.constant = 0
            nextButtonTopAnchor?.constant = 15
            skipButtonTopAnchor?.constant = 15
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded() // animate constraint changes
            
        }, completion: nil)
        
    }
    
    func moveControlsOffScreen() {
        
        pageControlBottomAnchor?.constant = 100
        nextButtonTopAnchor?.constant = -100
        skipButtonTopAnchor?.constant = -100
    }
    
    fileprivate func registerCells() {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LoginCell.self, forCellWithReuseIdentifier: loginCellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == pages.count {
            let loginCell = collectionView.dequeueReusableCell(withReuseIdentifier: loginCellId, for: indexPath) as! LoginCell
            self.loginCell = loginCell
            loginCell.loginController = self
            return loginCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PageCell
        let page = pages[indexPath.item]
        
        cell.page = page
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.bounds.width, height: view.bounds.height)
    }
    
    func profileImageViewTapped() {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            loginCell?.profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func handleRegister() {
        
        guard let email = loginCell?.emailTextField.text, let password = loginCell?.passwordTextField.text, let username = loginCell?.nameTextField.text else {
            print("AIDAN: Form is not valid!")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                
                print("AIDAN: error creating new firebase user: \(error!.localizedDescription)")
                return
                
            } else {
                
                self.loginCell?.nameTextField.text = ""
                self.loginCell?.emailTextField.text = ""
                self.loginCell?.passwordTextField.text = ""
                
                guard let uid = user?.uid else { return }
                
                // successfully created user, proceeding to upload selected profile picture
                let imageName = NSUUID().uuidString
                
                if let profileImage = self.loginCell?.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                    
                    storage.child(kPROFILEIMAGES).child("\(imageName).jpg").put(uploadData, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            
                            print("AIDAN: Error uploading selected profile image to firebase storage: \(error!.localizedDescription)")
                            return
                        }
                        
                        
                        // successfully uploaded profile image
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                            
                            let values = [kNAME: username, kEMAIL: email, kPROFILEIMAGEURL: profileImageUrl]
                            
                            // UPDATING USER DB WITH NEWLY CREATED USER
                            self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
                        }
                        
                    })
                }
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any]) {
        
        
        firebase.child(kUSERS).child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                print("error saving user details in firebase database: \(String(describing: error?.localizedDescription))")
            }
            
            let user = User()
            user.setValuesForKeys(values) // may crash if keys dont match
            
//            self.messagesController?.setupNavBarWithUser(user: user)
            self.messagesController = MessagesController()
            self.messagesController?.setupNavBarWithUser(user: user)
            self.present(UINavigationController(rootViewController: self.messagesController!), animated: true, completion: nil)
        })
    }
    
    func handleLogin() {
        guard let email = loginCell?.emailTextField.text, let password = loginCell?.passwordTextField.text else {
            print("AIDAN: Form is not valid!")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            self.loginCell?.emailTextField.text = ""
            self.loginCell?.passwordTextField.text = ""
            
            if error != nil {
                print("AIDAN: Unable to sign in to firebase: \(error!.localizedDescription)")
                return
            }
            print("logged in")
            self.messagesController = MessagesController()
            self.messagesController?.fetchUserNameAndSetUpNavBarTitle()
            self.present(UINavigationController(rootViewController: self.messagesController!), animated: true, completion: nil)
        })
    }
    
    func handleLoginOrRegister() {
        
        if loginCell?.loginRegisterSegmentedControls.selectedSegmentIndex == 0 {
            handleLogin()
        } else if loginCell?.loginRegisterSegmentedControls.selectedSegmentIndex == 1 {
            handleRegister()
        }
    }
    
    
}



