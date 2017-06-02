//
//  BookmarkController.swift
//  urcal
//
//  Created by Kilian Hiestermann on 23.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit
import Firebase

class BookmarkController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
   let cellId = "cellId"
    
    var post = [UserPost]()
    var bookmarks = [String]()
    var indexPaths = [IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        navigationItem.title = "Bookmarks"
        collectionView?.register(HomeControllerViewCell.self, forCellWithReuseIdentifier: cellId)
        getBookmarks()
        NotificationCenter.default.addObserver(self, selector: #selector(delateCell), name: .delateCell, object: nil)
    }
    
    // delate Cell by notification from HomeCollectionViewCell function: handleDeBookmark()
    func delateCell(notification: Notification) {
        let indexPath = notification.object as! NSIndexPath
        post.remove(at: indexPath.item)
        self.collectionView?.deleteItems(at: [indexPath as IndexPath])
        
        // reload items of the collection view to make shure that every cell has the right IndexPath
        let i =  self.collectionView?.indexPathsForVisibleItems
        self.collectionView?.reloadItems(at: i!)
    }
    
    // setting up cells
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeControllerViewCell
        cell.post = post[indexPath.item]
        self.indexPaths.append(indexPath)
        cell.indexPath = indexPath as NSIndexPath
        cell.bookmarked = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // height is widht of the frame + top View + logos + logo labels + paddings top and botton
        let height = (view.frame.width / 2) + 60 + 32 + 14 + 12
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // fetch bookmarks from Firebase
    fileprivate func getBookmarks(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        // getting the bookmars from the user
        let ref = FIRDatabase.database().reference().child("users").child(uid).child("bookmarks")
        ref.observe(.childAdded, with: { (snapshot) in
            let postId = snapshot.key
            // get the post from postId and from the Post the user of the post
            FIRDatabase.fetchPostWithId(postId: postId, completion: { (post) in
                FIRDatabase.fetchUserWithUid(uid: post.uid, completion: { (user) in
                    let bookmark = UserPost(user: user, post: post)
                    self.post.append(bookmark)
                    self.collectionView?.reloadData()
                })
            })
        }) { (err) in
            print(err)
        }
    }
}

