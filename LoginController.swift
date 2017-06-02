//
//  LoginController.swift
//  urcal
//
//  Created by Kilian Hiestermann on 06.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//
 
import UIKit
import Firebase



class LoginController: UIViewController {
    
    let backroundGif: UIImageView = {
        let bg = UIImageView()
        return bg
    }()
    
    let logoContainerView: UIView = {
        let view = UIView()
       // view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue:  175)
        return view
    }()
  
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dont have an account? Sign Up", for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    let loginAnonym: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Anonym Login", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLoginAnonym), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 1, alpha: 0.7)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
        
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 1, alpha: 0.7)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
       tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
        
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return button
    }()
    
    let blackOverlay: UIView = {
        let videoView = UIView()
        return videoView
    }()

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backroundGif)
        backroundGif.loadGif(name: "bg")
        backroundGif.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        navigationController?.isNavigationBarHidden = true
        view.addSubview(signUpButton)
        signUpButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -20, paddingRight: 0, width: 0, height: 20)
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        setuoInputFields()
        
    }
    
    fileprivate func setuoInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, loginAnonym])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: 0, height: 200)
        
    
    }

    func handleTextInputChange (){
        let isFormValid = emailTextField.text?.characters.count ?? 0>0 && passwordTextField.text?.characters.count ?? 0>0
        
        if isFormValid {
            loginButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            loginButton.isEnabled = true
            
        } else {
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
            loginButton.isEnabled = false
        }
    }
    
    func handleShowSignUp() {
        let signUpController = SingnUpController()
        navigationController?.pushViewController(signUpController, animated: true)
        
    }
    
    func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard  let pw = passwordTextField.text else { return }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: pw, completion: { (user, err) in
            if let err = err {
                print(err)
                return
            }
    
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return  }
            mainTabBarController.setupViewController()
            self.dismiss(animated: true, completion: nil)
            
        })
        
    }
    
    func handleLoginAnonym() {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, err) in
            if let err = err {
                print(err)
                return
            }
            guard let uid = user?.uid else { return }
            let values = ["username": "###hjkuiz###"]
            
            FIRDatabase.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    return
                }
                guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return  }
                mainTabBarController.setupViewController()
                self.dismiss(animated: true, completion: nil)
            })
        })
    }

}
