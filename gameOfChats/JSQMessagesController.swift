//
//  JSQMessagesController.swift
//  gameOfChats
//
//  Created by Aidan Aden on 3/7/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import AVFoundation
import IDMPhotoBrowser

class JSQMessagesController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //    var imageView = UIImageView(image: UIImage(named: "nedstark"))
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.darkGray)
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    let taillessIncomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegularTailless(), capInsets: .zero).incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    let taillessOutgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegularTailless(), capInsets: .zero).outgoingMessagesBubbleImage(with: UIColor.darkGray)
    
    var avatarImage: UIImage?
    
    var user: User? {
        didSet {
            
            setupNavBarWithUser(user: user!)
            
            if let url = URL(string: (user?.profileImageUrl)!) {
                
                let resource = ImageResource(downloadURL: url)
                KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil, completionHandler: { (image, err, cacheType, URL) in
                    
                    self.avatarImage = image
                })
            }
            
            observeMessages()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = JSQMessages[indexPath.row]       // receive message object from messages array
        
        if message.text != nil {
            
            if message.senderId == FIRAuth.auth()?.currentUser?.uid {
                cell.textView.textColor = UIColor.white
            } else {
                cell.textView.textColor = UIColor.black
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        let message = JSQMessages[indexPath.row]
        
        return message
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return JSQMessages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        
        let data = JSQMessages[indexPath.item] // obtains message from messages array
        var nextData: JSQMessage?
        
        if data.senderId == FIRAuth.auth()?.currentUser?.uid { // check if sender of message is current user
            
            if indexPath.item < JSQMessages.count - 1 {
                
                nextData = JSQMessages[indexPath.item + 1]
                
                if data.senderId == nextData?.senderId {
                    return taillessOutgoingBubble
                }
            }
            return outgoingBubble
            
        } else {
            
            if indexPath.item < JSQMessages.count - 1 {
                
                nextData = JSQMessages[indexPath.item + 1]
                
                if data.senderId == nextData?.senderId {
                    return taillessIncomingBubble
                }
            }
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = JSQMessages[indexPath.item]
        
        if indexPath.item % 10 == 0 {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item % 10 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = JSQMessages[indexPath.item]
        var avatar: JSQMessageAvatarImageDataSource
        
        if message.senderId != FIRAuth.auth()?.currentUser?.uid {
            
            avatar = JSQMessagesAvatarImageFactory.avatarImage(with: avatarImage, diameter: 70)
        } else {
            avatar = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: #imageLiteral(resourceName: "User"), diameter: 70)
        }
        
        return avatar
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        print("clicked!")
        let message = JSQMessages[indexPath.item]
        let messageObject = messages[indexPath.item]
        
        if message.isMediaMessage, messageObject.videoURL != nil {
            
            print("media detected!")
            let media = message.media as! VideoMessage
            let player = AVPlayer(url: media.fileURL!)
            let playerVC = AVPlayerViewController()
            playerVC.player = player
            self.present(playerVC, animated: true, completion: {
                playerVC.player?.play()
            })
            
        } else if message.isMediaMessage, messageObject.imageURL != nil {
            
            let media = message.media as! JSQPhotoMediaItem
            let photos = IDMPhoto.photos(withImages: [media.image])
            
            guard let browser = IDMPhotoBrowser(photos: photos) else { return }
            
            browser.displayDoneButton = false
            browser.animationDuration = 0.1
            browser.usePopAnimation = true
            
            self.present(browser, animated: true, completion: nil)
        }
    }
    
    
    var messages = [Message]()
    var JSQMessages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = FIRAuth.auth()?.currentUser?.uid
        self.senderDisplayName = FIRAuth.auth()?.currentUser?.email!
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    
    func setupNavBarWithUser(user: User) {
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 15
        profileImageView.layer.masksToBounds = true
        
        if let profileImageURL = user.profileImageUrl {
            
            let profileUrl = URL(string: profileImageURL)
            let resource = ImageResource(downloadURL: profileUrl!)
            profileImageView.kf.setImage(with: resource)
        }
        
        containerView.addSubview(profileImageView)
        
        // constraints for image view
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let nameLbl = UILabel()
        nameLbl.text = user.name
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLbl)
        
        nameLbl.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLbl.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLbl.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLbl.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        
        self.navigationItem.titleView = titleView
    }
    
    
    func observeMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else { return }
        
        let userMessagesRef = firebase.child(kUSERMESSAGES).child(uid).child(toId)
        
        userMessagesRef.observeSingleEvent(of: .value, with: { snapshot in
            
            let childrenCount = Int(snapshot.childrenCount)
            
            for snap in snapshot.children {
                
                let messageId = (snap as! FIRDataSnapshot).key
                let messagesRef = firebase.child(kMESSAGES).child(messageId)
                
                messagesRef.observeSingleEvent(of: .value, with: { snapshot in
                    
                    guard let dictionary = snapshot.value as? [String : Any] else { return }
                    
                    let message = Message(dictionary: dictionary)
                    
                    if self.messages.contains(message) {
                        print("YES contains")
                    }
                    
                    self.messages.append(message)
                    let jsqMessage = self.createJSQMessage(message: message)
                    self.JSQMessages.append(jsqMessage!)
                    
                    if childrenCount == self.messages.count {
                        
                        DispatchQueue.main.async {
                            
                            self.collectionView?.reloadData() // reload data on main q
                            self.finishReceivingMessage(animated: true)
                        }
                    }
                })
            }
        })
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = firebase.child(kMESSAGES).child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                
                let message = Message(dictionary: dictionary)
                
                self.messages.append(message)
                
                let jsqMessage = self.createJSQMessage(message: message)
                
                self.JSQMessages.append(jsqMessage!)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    // scroll to latest image message/index
                    self.finishReceivingMessage(animated: true)
                }
            })
        })

    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert: UIAlertAction) in
            
            self.handleUploadTap(type: kUTTypeImage)
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (alert: UIAlertAction) in
            
            self.handleUploadTap(type: kUTTypeMovie)
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { (alert: UIAlertAction) in
            
            self.scrollToBottom(animated: true)
        }
        
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if text != "" {
            
            let properties = [kTEXT: text] as [String: Any]
            sendMessageWithProperties(properties: properties)
        }
        
        self.finishSendingMessage(animated: true)
    }
    
    
    private func sendMessageWithProperties(properties: [String: Any]) {
        
        let messageRef = firebase.child(kMESSAGES).childByAutoId()
        let timeStamp: Int = Int(NSDate().timeIntervalSince1970)
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
            
            
            let userMessagesRef = firebase.child(kUSERMESSAGES).child(senderId).child(toId)
            let messageId = messageRef.key
            
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserRef = firebase.child(kUSERMESSAGES).child(toId).child(senderId)
            recipientUserRef.updateChildValues([messageId: 1])
        }
    }
    
    func handleUploadTap(type: CFString) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true // enables editing of photos
        imagePicker.mediaTypes = [type as String] // sets available media types
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {   // selected a video
            
            handleVideoSelectedForUrl(videoFileURL: videoUrl)
            
        } else {
            
            handleImageSelectedWithInfo(info: info) // selected an image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func handleVideoSelectedForUrl(videoFileURL: URL) {
        
        let videoName = NSUUID().uuidString
        let videoFileName = "MessageVideo/" + videoName + ".mov"
        let uploadTask = storage.child(kMESSAGEVIDEOS).child(videoFileName).putFile(videoFileURL, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("Failed to upload video to firebase: \(error!.localizedDescription)")
            }
            
            if let storageUrl = metadata?.downloadURL()?.absoluteString {
                
                self.sendMessageWithVideoUrl(videoUrl: storageUrl, videoFileURL: videoFileURL)
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            
            if let completedUnitCount = snapshot.progress?.completedUnitCount, let totalUnitCount = snapshot.progress?.totalUnitCount {
                
                let completedPercentage: Float64 = Float64(completedUnitCount)*100 / Float64(totalUnitCount)
                self.navigationItem.title = String(format: "%.0f", completedPercentage) + "%"
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            
            self.navigationItem.title = self.user!.name!
        }
    }
    
    func sendMessageWithVideoUrl(videoUrl: String, videoFileURL: URL) {
        
        if let thumbnailImage = thumbnailImageForFileUrl(videoFileURL: videoFileURL) {
            
            uploadImageToFirebase(image: thumbnailImage, completion: { imageUrl in
                
                let properties = [kTEXT: kVIDEOMESSAGE, kVIDEOURL: videoUrl, kIMAGEURL: imageUrl, kIMAGEWIDTH : thumbnailImage.size.width, kIMAGEHEIGHT : thumbnailImage.size.height] as [String : Any]
                
                self.sendMessageWithProperties(properties: properties)
            })
        }
    }
    
    func thumbnailImageForFileUrl(videoFileURL: URL) -> UIImage? {
        
        let asset = AVAsset(url: videoFileURL)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try assetGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil) // tries to obtain image of first frame of video
            
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            
            print(err)
        }
        
        return nil
    }
    
    func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        
        let properties = [kTEXT: kIMAGEMESSAGE, kIMAGEURL: imageUrl, kIMAGEWIDTH : image.size.width, kIMAGEHEIGHT : image.size.height] as [String : Any]
        
        sendMessageWithProperties(properties: properties)
    }
    
    func handleImageSelectedWithInfo(info: [String: Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            uploadImageToFirebase(image: selectedImage, completion: { imageUrl in
                
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirebase(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        
        let imageName = NSUUID().uuidString
        let storageRef = storage.child(kMESSAGEIMAGES).child(imageName)
        
        let uploadData = UIImageJPEGRepresentation(image, 0.2)
        
        if let upload = uploadData {
            
            storageRef.put(upload, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    
                    print("failed to upload message image: \(error!.localizedDescription)")
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    completion(imageUrl)
                }
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}


