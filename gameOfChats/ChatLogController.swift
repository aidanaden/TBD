//
//  ChatLogController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 22/6/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cellId = "CollectionViewCellId"
    
    var user: User? {
        didSet {
            self.navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else { return }
        
        let userMessagesRef = firebase.child(kUSERMESSAGES).child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = firebase.child(kMESSAGES).child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                
                let message = Message(dictionary: dictionary)
                
                self.messages.append(message)
            
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    // scroll to latest image message/index
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        })
    }
    
    let inputTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0) // adds top and bottom paddings
//        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0)  adds paddings for scroll indicator
        collectionView?.backgroundColor = UIColor.white
        collectionView?.keyboardDismissMode = .interactive // allow keyboard drag down effect
        collectionView?.alwaysBounceVertical = true // allow for bouncy effect when dragging view up and down
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        

        
        setupKeyboardObservers()
    }
    
    lazy var inputContainerView: UIView = {
       
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = #imageLiteral(resourceName: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        
        containerView.addSubview(uploadImageView)
        
        // upload Image View constraints
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let sendBtn = UIButton(type: .system)
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(sendBtn)
        
        // sendBtn constraints
        sendBtn.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendBtn.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendBtn.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendBtn.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(self.inputTextField)
        
        // inputTextField constraints
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 10).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendBtn.leftAnchor, constant: 10).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(seperatorLineView)
        
        // constraints
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    func handleUploadTap() {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true // enables editing of photos
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            uploadImageToFirebase(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirebase(image: UIImage) {
        
        let imageName = NSUUID().uuidString
        let storageRef = storage.child(kMESSAGEIMAGES).child(imageName)
        
        let uploadData = UIImageJPEGRepresentation(image, 0.2)
        
        if let upload = uploadData {
            
            storageRef.put(upload, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    
                    print("failed to upload message image: \(error!.localizedDescription)")
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                }
            })
        }
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return self.inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self) // remove keyboard observer in order to prevent memory leak
    }
    
    func handleKeyboardDidShow() {
        
        if messages.count > 0 {
            
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func handleKeyboardWillHide(notification: Notification) {
        
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration, animations: {    // run this to apply cool animation effect
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillShow(notification: Notification) {
        
        let keyboardFrame: CGRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        containerViewBottomAnchor?.constant = -keyboardFrame.height
        UIView.animate(withDuration: keyboardDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func handleSend() {
        
        let properties = [kTEXT: inputTextField.text!]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        
        let properties = [kIMAGEURL: imageUrl, kIMAGEWIDTH : image.size.width, kIMAGEHEIGHT : image.size.height, ] as [String : Any]
        
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String: Any]) {
        
        let messageRef = firebase.child(kMESSAGES).childByAutoId()
        let timeStamp = "\(NSDate().timeIntervalSince1970)"
        let toId = user!.id!
        let senderId = FIRAuth.auth()!.currentUser!.uid
        var values = [kTOUSERID: toId, kSENDERID: senderId, kDATE: timeStamp] as [String : Any]
        
        // append properties dictionary to values
        // to access properties, key = $0, value = $1
        properties.forEach({ values[$0] = $1 })
        
        messageRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print("AIDAN: Failed to send message to firebase: \(String(describing: error))")
            }
            
            self.inputTextField.text = ""
            
            let userMessagesRef = firebase.child(kUSERMESSAGES).child(senderId).child(toId)
            let messageId = messageRef.key
            
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserRef = firebase.child(kUSERMESSAGES).child(toId).child(senderId)
            recipientUserRef.updateChildValues([messageId: 1])
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = messages[indexPath.item]
        
        var height: CGFloat = 80
        
        // get estimated height based on text
        if let text = message.text {
            
            height = estimateFrameForText(text: text).height + 18
            
        } else if let imageWidth = message.messageImageWidth?.floatValue, let imageHeight = message.messageImageHeight?.floatValue {
            // set height of cell to height of image
            
            // h1 / w1 = h2 / w2 
            // h1 = h2 / w2 * w1
            
            height = CGFloat((imageHeight/imageWidth) * 200)
        }
        
        let width = UIScreen.main.bounds.width // use width of window instead in order to solve layout problems caused by using inputAccessoryView -> width becomes incorrect and layout messes up when landscape
        
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 10000)
        let option = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: option, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let message = messages[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        cell.textView.text = message.text
        
        setupCells(cell: cell, message: message)
        
        // modify bubble width when there is text
        if let text = message.text {
            
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 26
            cell.textView.isHidden = false
            
        } else if message.imageURL != nil { // if it is an image message, modify width based on image width
            
            cell.textView.isHidden = true
            cell.bubbleWidthAnchor?.constant = 200
        }
        
        
        return cell
    }
    
    private func setupCells(cell: ChatMessageCell, message: Message) {
        
        guard let profileUrl = self.user?.profileImageUrl, let profileURL = URL(string: profileUrl) else { return }
        
        let resource = ImageResource(downloadURL: profileURL)
        
        cell.profileImageView.kf.setImage(with: resource)
        
        if let messageImageUrl = message.imageURL, let messageImageURL = URL(string: messageImageUrl) {
            
            let messageResource = ImageResource(downloadURL: messageImageURL)
            
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.messageImageVew.kf.setImage(with: messageResource, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            
            cell.messageImageVew.isHidden = false
            
        } else {
            
            cell.messageImageVew.isHidden = true
        }
        
        if message.senderId == FIRAuth.auth()?.currentUser?.uid {
            // outgoing blue
            if message.imageURL != nil {
                
                cell.bubbleView.backgroundColor = UIColor.clear
                
            } else {
                
                cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
                cell.textView.textColor = UIColor.white // set color as color may change due to collection view reusing cells
            }
            
            cell.profileImageView.isHidden = true // hide profile image when user sends outgoing message
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            // incoming view
            if message.imageURL != nil {
                
                cell.bubbleView.backgroundColor = UIColor.clear
                
            } else {
                
                cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
                cell.textView.textColor = UIColor.black
            }
            
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    // custom zooming logic
    func performZoomInForImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
    
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        guard let frame = startingFrame else { return }
        let zoomImageView = UIImageView(frame: frame)
        zoomImageView.image = startingImageView.image
        zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomImageView.isUserInteractionEnabled = true
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView!.alpha = 1
                self.inputContainerView.alpha = 0
                
                // math of similar rectangles
                // h2 / w2 = h1 / w1
                // h2 = h1 / w1 * w2
                
                let height = (self.startingFrame!.height/self.startingFrame!.width) * keyWindow.frame.width
                
                zoomImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomImageView.center = keyWindow.center
                
            }, completion: nil)
            
        }
        
    }
    
    func handleZoomOut(tapGesure: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesure.view {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed: Bool) in
                
                zoomOutImageView.removeFromSuperview()
                self.blackBackgroundView?.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
            
        }
    }
}









