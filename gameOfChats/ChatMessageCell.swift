//
//  ChatMessageCell.swift
//  gameOfChats
//
//  Created by Aidan Aden on 23/6/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import AVFoundation


class ChatMessageCell: UICollectionViewCell {
    
    var chatLogController: ChatLogController?
    
    var message: Message?
    
    let activityIndicatorView: UIActivityIndicatorView = {
       
        let aiView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        aiView.translatesAutoresizingMaskIntoConstraints = false
        aiView.hidesWhenStopped = true
        return aiView
    }()
    
    lazy var playButton: UIButton = {
       
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        button.tintColor = UIColor.white
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    func handlePlay() {
        
        guard let stringUrl = message?.videoURL, let url = URL(string: stringUrl) else { return }
        
        player = AVPlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bubbleView.bounds// must specify frame in order to video to play on screen, otherwise only audio will play
        bubbleView.layer.addSublayer(playerLayer!)
        
        player?.play()
        playButton.isHidden = true
        activityIndicatorView.startAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        activityIndicatorView.stopAnimating()
    }
    
    let textView: UITextView = {
        
        let tv = UITextView()
        tv.isEditable = false
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        tv.isScrollEnabled = false
        return tv
    }()
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.layer.cornerRadius = 16
        imageview.layer.masksToBounds = true
        imageview.contentMode = .scaleAspectFill
        return imageview
    }()
    
    lazy var messageImageVew: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.layer.cornerRadius = 16
        imageview.layer.masksToBounds = true
        imageview.contentMode = .scaleAspectFill
        imageview.isUserInteractionEnabled = true
        imageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap(tapGesture:))))
        
        return imageview
    }()
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        
        //PRO TIP: DONT PERFORM A LOT OF CUSTOM LOGIC INSIDE OF VIEW CLASS: PERFORM IN CONTROLLER CLASS
        
        if message?.videoURL != nil {
            return 
        }
        
        if let imageView = tapGesture.view as? UIImageView {
            
            self.chatLogController?.performZoomInForImageView(startingImageView: imageView)
        }
    }
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        bubbleView.addSubview(messageImageVew)
        
        // message image view constraints 
        
        messageImageVew.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageVew.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageVew.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageVew.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        bubbleView.addSubview(playButton)
        
        // play button constraints
        
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubbleView.addSubview(activityIndicatorView)
        
        // activity indicator view 
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        // bubble view constraints

        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
    
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 3).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        
        // text view constraints
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
       
        // profile image view constraints
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}








