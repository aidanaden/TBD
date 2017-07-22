//
//  LoginVC+handlers.swift
//  gameOfChats
//
//  Created by Aidan Aden on 22/6/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//


import UIKit
import Firebase

extension LoginVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let username = nameTextField.text else {
            print("AIDAN: Form is not valid!")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                print("AIDAN: error creating new firebase user: \(error!.localizedDescription)")
                return
                
            } else {
                
                guard let uid = user?.uid else { return }
                
                // successfully created user, proceeding to upload selected profile picture
                let imageName = NSUUID().uuidString
                
                if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {

                    storage.child(kPROFILEIMAGES).child("\(imageName).jpg").putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        
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
            
            self.messagesController?.setupNavBarWithUser(user: user)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("AIDAN: Form is not valid!")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print("AIDAN: Unable to sign in to firebase: \(error!.localizedDescription)")
                return
            }
            
            self.messagesController?.fetchUserNameAndSetUpNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleLoginOrRegister() {
        
        if loginRegisterSegmentedControls.selectedSegmentIndex == 0 {
            handleLogin()
        } else if loginRegisterSegmentedControls.selectedSegmentIndex == 1 {
            handleRegister()
        }
    }
}


