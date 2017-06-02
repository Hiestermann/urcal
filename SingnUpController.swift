//
//  ViewController.swift
//  urcal
//
//  Created by Kilian Hiestermann on 01.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit
import Firebase

class SingnUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let backroundGif: UIImageView = {
        let bg = UIImageView()
        return bg
    }()
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo.png").withRenderingMode(.alwaysOriginal), for: .normal)
        
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.5)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.5)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
        
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.5)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
        
    }()
    
    let singUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SignUP", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        return button
    
    }()
    
    let alreadyHaveAnAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dont have an account? Sign Up", for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAnAccount), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backroundGif)
        backroundGif.loadGif(name: "bg")
        backroundGif.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil , bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupInputFields()
        
        view.addSubview(alreadyHaveAnAccountButton)
        alreadyHaveAnAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: -20, paddingRight: -20, width: 0, height: 20)
      
    }

    fileprivate func setupInputFields() {
 
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, singUpButton])

        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -40, width: 0, height: 200)
       
    }
    
    
    func handleTextInputChange (){
        let isFormValid = emailTextField.text?.characters.count ?? 0>0 && passwordTextField.text?.characters.count ?? 0>0 && usernameTextField.text?.characters.count ?? 0>0
        
        if isFormValid {
            singUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            singUpButton.isEnabled = true
            
        } else {
            singUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
            singUpButton.isEnabled = false
        }
    }
    
    // get Photo for the User
    
    func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }else if let originalImage = info ["UIImagePickerControllerOriginalImage"] as? UIImage{
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    func handleAlreadyHaveAnAccount(){
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    func handleSignUp() {
        
        
        guard let email = emailTextField.text, email.characters.count > 0 else { return }
        guard let username = usernameTextField.text, username.characters.count > 0 else { return }
        guard let pw = passwordTextField.text, pw.characters.count > 0 else { return }
        
        
        FIRAuth.auth()?.createUser(withEmail: email, password: pw, completion: { (user: FIRUser?,error: Error?) in
            
            guard let image = self.plusPhotoButton.imageView?.image else { return }
            
            guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
            
            let filename = NSUUID().uuidString
            
            FIRStorage.storage().reference().child("profile_images").child(filename).put(uploadData, metadata: nil) { (metadata, err) in
                
                if let err = err{
                    print("Faild", err)
                    return
                    
                }
                
                guard let profileImageURL = metadata?.downloadURL()?.absoluteString else { return }
                                
                if let err = error{
                    print("FAIL: ",  err)
                    
                }
                
                print("Succesfully create user: ", user?.uid ?? "")
                
                guard let uid = user?.uid else { return  }
                let usernameValue = ["username": username, "profileImageURL": profileImageURL]
                let value = [uid: usernameValue]
                
                FIRDatabase.database().reference().child("users").updateChildValues(value, withCompletionBlock: { (err, ref) in
                    
                    if let err = err {
                        print(err)
                        return
                    }
                    guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return  }
                    mainTabBarController.setupViewController()
                    self.dismiss(animated: true, completion: nil)
                })
                
                let followValues = [uid: 1]
                FIRDatabase.database().reference().child("following").child(uid).updateChildValues(followValues){ (err, ref) in
                    if let err = err {
                        print("Faild to implement following: ", err)
                        return
                    }
   
                }
            }
        })
    }

}








