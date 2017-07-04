//
//  LoginCell.swift
//  gameOfChats
//
//  Created by Aidan Aden on 3/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit


class LoginCell: UICollectionViewCell {
    
    var vC: viewController? {
        didSet {
            print("set vc!")
            loginRegisterBtn.addTarget(vC, action: #selector(vC!.handleLoginOrRegister), for: .touchUpInside)
            profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: vC, action: #selector(vC!.profileImageViewTapped)))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
        
        backgroundColor = UIColor.gray
        addSubview(inputsContainerView)
        addSubview(loginRegisterBtn)
        addSubview(profileImageView)
        addSubview(loginRegisterSegmentedControls)
        
        setUpInputsContainer()
        setUpLoginRegisterBtn()
        setUpProfileImageView()
        setUpLoginRegisterSegmentedControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var messagesController: MessagesController?
    
    let inputsContainerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(r: 74, g: 77, b: 95)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    let loginRegisterBtn: UIButton = {
        
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor(r: 74, g: 77, b: 95)
        button.setTitle("Register", for: UIControlState.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.layer.cornerRadius = 5
        
        return button
    }()
    
    let nameTextField: UITextField = {
        
        let tf = UITextField()
        var mutableString = NSMutableAttributedString()
        let placeHolder = "Name"
        tf.attributedPlaceholder = customPlaceholder(placeholder: placeHolder)
        tf.textColor = UIColor.white
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.layer.masksToBounds = true
        return tf
    }()
    
    let nameSeperatorView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        
        let tf = UITextField()
        let placeHolder = "Email"
        tf.textColor = UIColor.white
        tf.attributedPlaceholder = customPlaceholder(placeholder: placeHolder)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeperatorView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: UITextField = {
        
        let tf = UITextField()
        let placeHolder = "Password"
        tf.isSecureTextEntry = true
        tf.textColor = UIColor.white
        tf.attributedPlaceholder = customPlaceholder(placeholder: placeHolder)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordSeperatorView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gameofthrones_splash")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    
    
    lazy var loginRegisterSegmentedControls: UISegmentedControl = {
        
        let segment = UISegmentedControl(items: ["Login", "Register"])
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.tintColor = UIColor.white
        segment.layer.cornerRadius = 5
        segment.backgroundColor = UIColor(r: 74, g: 77, b: 95)
        segment.selectedSegmentIndex = 1
        
        segment.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return segment
    }()
    
    func handleLoginRegisterChange() {
        
        let title = loginRegisterSegmentedControls.titleForSegment(at: loginRegisterSegmentedControls.selectedSegmentIndex)
        loginRegisterBtn.setTitle(title, for: .normal)
        
        
        
        // change height of inputView
        inputsViewHeightAnchor?.constant = loginRegisterSegmentedControls.selectedSegmentIndex == 0 ? 100: 150
        
        nameTextFieldHeightAnchor?.isActive = false
        
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControls.selectedSegmentIndex == 0 ? 0: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        nameSeperatorHeightAnchor?.isActive = false
        nameSeperatorHeightAnchor = nameSeperatorView.heightAnchor.constraint(equalToConstant: loginRegisterSegmentedControls.selectedSegmentIndex == 0 ? 0: 1)
        nameSeperatorHeightAnchor?.isActive = true
        
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControls.selectedSegmentIndex == 0 ? 1/2: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControls.selectedSegmentIndex == 0 ? 1/2: 1/3)
        
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    
    
    
    func setUpLoginRegisterSegmentedControl() {
        
        loginRegisterSegmentedControls.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loginRegisterSegmentedControls.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControls.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControls.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setUpProfileImageView() {
        
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControls.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setUpLoginRegisterBtn() {
        
        loginRegisterBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loginRegisterBtn.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterBtn.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    var inputsViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var nameSeperatorHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setUpInputsContainer() {
        
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeperatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeperatorView)
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(passwordSeperatorView)
        
        // need x, y and height contstraints
        
        inputsContainerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: widthAnchor, constant: -24).isActive = true
        inputsViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsViewHeightAnchor?.isActive = true
        
        nameTextField.anchorWithConstantsToTop(inputsContainerView.topAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0)
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        nameSeperatorView.anchorToTop(nameTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: nil)
        nameSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeperatorHeightAnchor = nameSeperatorView.heightAnchor.constraint(equalToConstant: 1)
        nameSeperatorHeightAnchor?.isActive = true
        
        emailTextField.anchorWithConstantsToTop(nameTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0)
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        emailSeperatorView.anchorToTop(emailTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: nil)
        emailSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        passwordTextField.anchorWithConstantsToTop(emailTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0)
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        passwordSeperatorView.anchorToTop(passwordTextField.bottomAnchor, left: inputsContainerView.leftAnchor, bottom: nil, right: nil)
        passwordSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}





