//
//  UserPostsCells.swift
//  urcal
//
//  Created by Kilian Hiestermann on 25.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit

class UserPostsCells: UITableViewCell {
    
    var post: Post?{
        didSet{
            guard let postImageUrl = post?.imageUrl else { return }
            guard let geoImageUrl = post?.geoImageUrl else  { return }
            
            postImage.loadImageUsingCacheWithUrlString(urlString: postImageUrl)
            geoImageView.loadImageUsingCacheWithUrlString(urlString: geoImageUrl)
        }
    }
    
    let geoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .blue
        return iv
    }()
    
    let postImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .red
        return iv
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "sharethis").withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        return button
    }()
    
    lazy var arrowLikeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        return button
    }()
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        return button
    }()
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        print("#####", reuseIdentifier)
        setUpCells()
    }
    
    
    fileprivate func setUpCells(){
        addSubview(postImage)
        postImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        addSubview(geoImageView)
        geoImageView.anchor(top: topAnchor, left: postImage.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 0)
        
        setupStackView()
    }
    
    fileprivate func setupStackView(){
        
        let firstStackView = UIStackView(arrangedSubviews: [shareButton, arrowLikeButton])
        firstStackView.distribution = .fillEqually
        firstStackView.axis = .horizontal
        addSubview(firstStackView)
        firstStackView.anchor(top: topAnchor, left: geoImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 3, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        let secondStackView = UIStackView(arrangedSubviews: [commentButton, bookmarkButton])
        secondStackView.distribution = .fillEqually
        secondStackView.axis = .horizontal
        addSubview(secondStackView)
        secondStackView.anchor(top: firstStackView.bottomAnchor, left: geoImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 2, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
