//
//  ChatInputContainerView.swift
//  gameOfChats
//
//  Created by Aidan Aden on 28/6/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    var chatLogController: ChatLogController? {
        
        didSet {
            sendBtn.addTarget(chatLogController, action: #selector(chatLogController?.handleSend), for: .touchUpInside)
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(chatLogController?.handleUploadTap)))
        }
    }
    
    let sendBtn: UIButton = {
        
        let sendBtn = UIButton(type: .system)
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        return sendBtn
    }()
    
    
    let uploadImageView: UIImageView = {
        
        let uploadImageView = UIImageView()
        uploadImageView.image = #imageLiteral(resourceName: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        return uploadImageView
    }()
    
    
    lazy var inputTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        addSubview(uploadImageView)
        
        // upload Image View constraints
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(sendBtn)
        
        // sendBtn constraints
        sendBtn.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendBtn.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendBtn.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendBtn.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        
        addSubview(inputTextField)
        
        // inputTextField constraints
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 10).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendBtn.leftAnchor, constant: 10).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(seperatorLineView)
        
        // constraints
        seperatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        seperatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
