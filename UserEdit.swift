//
//  UserEdit.swift
//  urcal
//
//  Created by Kilian Hiestermann on 01.06.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit

class UserEdit: UIViewController {
    
    let userImage: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.cornerRadius = 50
        image.image = UIImage(named: "profil_dummy")
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
    }
    
    fileprivate func setupView() {
        view.backgroundColor = .lightGray
    
    }
    
}
