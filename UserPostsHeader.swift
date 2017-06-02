//
//  UserPostsHeader.swift
//  urcal
//
//  Created by Kilian Hiestermann on 31.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit

class UserPostHeader: UITableViewHeaderFooterView {

    var user: User? {
        didSet{
            guard let userName = user?.username else { return }
            guard let profileImageUrl = user?.profileImageUrl else { return }
            
            userNameLabel.text = userName
            if profileImageUrl != ""{
                userImage.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
        }
    }
    
    let userImage: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.cornerRadius = 50
        image.image = UIImage(named: "profil_dummy")
        return image
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let editeProfileButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.setTitle("Edite Profile", for: .normal)
        button.addTarget(self, action: #selector(handleShowEditeProfile), for: .touchUpInside)
        return button
    }()
    
    func handleShowEditeProfile(){
        let userEdit = UserEdit()
    
        let navController = UINavigationController(rootViewController: userEdit)
        
        present(navController, animated: true, completion: nil)
        
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addSubview(userImage)
        userImage.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        userImage.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -100).isActive = true
    
        addSubview(userNameLabel)
        userNameLabel.anchor(top: userImage.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 40)
        userNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(editeProfileButton)
        editeProfileButton.anchor(top: nil, left: userImage.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        editeProfileButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    
    fileprivate func fetchUserInfos() {
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
