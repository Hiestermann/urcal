//
//  UserPostEdit.swift
//  urcal
//
//  Created by Kilian Hiestermann on 26.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit

class UserPostEdit: UIViewController{
    
    var post: Post?{
        didSet{
            guard let postImageUrl = post?.imageUrl else { return }
            guard let geoImageUrl = post?.geoImageUrl else  { return }
            
            postImage.loadImageUsingCacheWithUrlString(urlString: postImageUrl)
            geoImageView.loadImageUsingCacheWithUrlString(urlString: geoImageUrl)
        }
    }
    
    var postImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .red
        return iv
    }()
    
    let geoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .blue
        return iv
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.isOpaque = false
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.addSubview(closeButton)
        closeButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
