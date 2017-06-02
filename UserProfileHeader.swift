//
//  UserProfileHeader.swift
//  urcal
//
//  Created by Kilian Hiestermann on 03.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit
import Firebase


class UserProfileHeader: UICollectionViewCell {
    
    
    var user: User?{
        didSet{
  
            setupProfileImage()
            usernameLable.text = self.user?.username
            setupEditFollowButton()
        }
        
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 80/2
        iv.clipsToBounds = true
        return iv
    
    }()
    
    let usernameLable: UILabel = {
        let lable = UILabel()
        lable.text = "username"
        lable.font = UIFont.boldSystemFont(ofSize: 14)
        return lable
    
    }()
    
    
    let gridButton: UIButton =  {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        return button
    
    }()
    
    let listButton: UIButton =  {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        return button
        
    }()
    
    let bookmarkButton: UIButton =  {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        return button
        
    }()
    
    let postLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSMutableAttributedString(string: "post", attributes: [NSForegroundColorAttributeName: UIColor.lightGray,  NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
            
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSMutableAttributedString(string: "post", attributes: [NSForegroundColorAttributeName: UIColor.lightGray,  NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
        
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSMutableAttributedString(string: "post", attributes: [NSForegroundColorAttributeName: UIColor.lightGray,  NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
        
    }()
    
    lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edite Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor =  UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditeProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        
        setupButtonToolBar()
        
        addSubview(usernameLable)
        usernameLable.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        setupUserStatsView()
        
        addSubview(profileButton)
        profileButton.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil , right: followingLabel.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: 0, height: 34)
        
    }
    
    
    fileprivate func setupUserStatsView(){
        let stackView = UIStackView(arrangedSubviews: [postLabel, followersLabel, followingLabel])
        
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: usernameLable.topAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: -12, width: 0, height: 0)
    
    }
    
    
    fileprivate func setupButtonToolBar (){
   
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 2)
        
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 2)
        
    }
    
    
    fileprivate func setupProfileImage() {
        
        guard let userProfileImageURL = user?.profileImageUrl else { return }
        
        guard let url = URL(string: userProfileImageURL) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            if let err = err{
                print("Error:", err)
                
            }
            
            guard let data = data else { return }
            
            let image = UIImage(data: data)
            
            DispatchQueue.main.sync {
                self.profileImageView.image = image
                
            }
            
            }.resume()
    }
    
    fileprivate func setupEditFollowButton() {
        guard let currendLoggedInUserId = FIRAuth.auth()?.currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currendLoggedInUserId == userId{
        }else {
            
            //follow Check
            FIRDatabase.database().reference().child("following").child(currendLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.profileButton.setTitle("Unfollow", for: .normal)
                    self.profileButton.backgroundColor = .white
                    self.profileButton.setTitleColor(.black, for: .normal)
                    self.profileButton.layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
                } else {
                    self.profileButton.setTitle("Follow", for: .normal)
                    self.profileButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
                    self.profileButton.setTitleColor(.white, for: .normal)
                    self.profileButton.layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
            }
                
                
            }, withCancel: { (err) in
                print(err)
            })
            
            
        }
    }
    
    func handleEditeProfileOrFollow() {
        guard let currendLoggedInUserId = FIRAuth.auth()?.currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        let ref = FIRDatabase.database().reference().child("following").child(currendLoggedInUserId)
        
        if profileButton.titleLabel?.text == "Unfollow" {
            
            // unfollow User
            ref.child(userId).removeValue(completionBlock: { (err, ref) in
                if let err = err {
                    print("faild to unfollow User: ", err)
                }
            })
            setupEditFollowButton()
        }else{
            
            //follow USer
            let values = [userId: 1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Faild to follow: ", err)
                    return
                }
                print("success, now you follow: ", self.user?.uid ?? "")
                self.setupEditFollowButton()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
