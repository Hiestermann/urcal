//
//  UserProfileController.swift
//  urcal
//
//  Created by Kilian Hiestermann on 02.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit
import Firebase


class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
   
    
    let cellId = "cellId"
    
    var user: User?
    
    var posts = [Post]()
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        navigationItem.title = FIRAuth.auth()?.currentUser?.uid
        
        fetchUserPosts()
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        collectionView?.register(UserProfileCells.self, forCellWithReuseIdentifier: cellId)
        self.view.endEditing(true)
        
        setupLogOutButton()
    }
    
    fileprivate func setupLogOutButton() {
     //   navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(handleLogOut))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(reload))
        
    }
    
    // setting up header

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
        header.user = self.user
        return header
    }
    
    //setting up cells
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfileCells
        
        cell.post = posts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width - 2)/3
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    fileprivate func fetchUserPosts(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        FIRDatabase.database().reference().child("users").child(uid).child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
           guard let postIdDictionary = snapshot.value as? [String: Any] else { return }
            postIdDictionary.forEach({ (key, value) in
                FIRDatabase.fetchPostWithId(postId: key, completion: { (post) in
                    self.posts.append(post)
                    self.collectionView?.reloadData()

                })
            })

        }) { (err) in
            print(err)
        }
    }
    
//    fileprivate func fetchUser() {
//        
//        
//        let uid = userId ?? (FIRAuth.auth()?.currentUser?.uid ?? "")
//        
//        FIRDatabase.fetchUserWithUid(uid: uid) { (user) in
//            self.user = user
//            self.navigationItem.title = self.user?.username
//            self.collectionView?.reloadData()
//            self.fetchOrderdPost()
//        }
//
//    }   
//    
//   fileprivate func fetchOrderdPost() {
//    
//    let uid = userId ?? (FIRAuth.auth()?.currentUser?.uid ?? "")
//    
//    
//    let ref =  FIRDatabase.database().reference().child("post").child(uid)
//    ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
//        
//        guard let dictionary = snapshot.value as? [String: Any] else { return }
//        guard let user = self.user else { return }
//        guard let post = Post(dictionary) else { return }
//        let userpost = UserPost(user: user, post: post)
//        self.posts.insert(post, at: 0)
//        self.collectionView?.reloadData()
//    }) { (err) in
//        print(err)
//    }
//    
//    }

    func reload(){
    self.collectionView?.reloadData()
    }
    
    func handleLogOut() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do{
                try FIRAuth.auth()?.signOut()
                let loginController = LoginController()
                let navController =  UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
                
            } catch let singOutErr {
                print("faild to log out", singOutErr)
            }
            
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

}


