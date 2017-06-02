//
//  UserProfileCells.swift
//  urcal
//
//  Created by Kilian Hiestermann on 12.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit

class UserProfileCells: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            
            guard let imageUrl = post?.imageUrl else { return }
            
            self.imageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
        }
    
    }
   
    var imageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
