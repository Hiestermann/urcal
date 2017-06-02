//
//  Extensions.swift
//  urcal
//
//  Created by Kilian Hiestermann on 01.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit
import Firebase

extension UIColor{
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        
        
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    
    }
    
}

extension UIView{
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top{
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left{
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom{
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right{
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        }
        
        if width != 0{
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0{
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
            
        }
    }
    
}

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    
    
    func loadImageUsingCacheWithUrlString(urlString: String){
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        let url = URL(string: urlString )!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
                
            }
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = UIImage(data:data!)
                }
            }
        })
        
        task.resume()
        
    
    }
}

extension FIRDatabase {
    static func fetchUserWithUid(uid: String, completion: @escaping (User) -> ()){
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User(uid: uid, dictionary: userDictionary)
            
            completion(user)
            
            
        }) { (err) in
            print(err)
        }
    }
    
    static func fetchPostWithId(postId: String, completion: @escaping (Post) -> ()){
        FIRDatabase.database().reference().child("posts").child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let postDictionary = snapshot.value as? [String: Any] else { return }
            
            let post = Post(postId: postId, dictionary: postDictionary)
            
            completion(post)
            
        }) { (err) in
            print(err)
        }
        
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
        
    }
}

extension Notification.Name {
    static let setUpMap = Notification.Name("setupMap")
    static let refreshHomeController =  Notification.Name("refreshProfileController")
    static let delateCell = Notification.Name("delateCell")
    static let refreshResults = Notification.Name("refreshResults")
    static let createAnnotation = Notification.Name("createAnnotation")
    static let sendAnnoitation = Notification.Name("sendAnnoitation")
}
