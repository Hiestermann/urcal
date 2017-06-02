//
//  UserPostsView.swift
//  urcal
//
//  Created by Kilian Hiestermann on 25.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit
import Firebase

class UserPostsView: UITableViewController{
    
    var user: User?
    
    var posts = [Post]()
    
    let cellId = "cellId"
    let headerId = "headerId"
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(handleLogOut))
        
        fetchUser()
        fetchUserPosts()
        
        tableView.register(UserPostsCells.self, forCellReuseIdentifier: cellId)
        tableView.register(UserPostHeader.self, forHeaderFooterViewReuseIdentifier: headerId)
        
    }
    
    // setting up Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId) as! UserPostHeader
        header.user = user
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    // SettingUp TableViewCells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserPostsCells
        cell.post = posts[indexPath.item]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userPostEdit = UserPostEdit()
        present(userPostEdit, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let uid = posts[indexPath.item].uid
        let postId = posts[indexPath.item].postId
        
        FIRDatabase.database().reference().child("posts").child(postId).removeValue()
        FIRDatabase.database().reference().child("users").child(uid).child("posts").child(postId).removeValue()
        posts.remove(at: indexPath.item)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    fileprivate func fetchUserPosts() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        FIRDatabase.database().reference().child("users").child(uid).child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let postIdDictionary = snapshot.value as? [String: Any] else { return }
            postIdDictionary.forEach({ (key, value) in
                FIRDatabase.fetchPostWithId(postId: key, completion: { (post) in
                    self.posts.append(post)
                    self.tableView.reloadData()
                })
            })
            
        }) { (err) in
            print(err)
        }
    }
    
    fileprivate func fetchUser(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }

        FIRDatabase.fetchUserWithUid(uid: uid) { (user) in
            self.user = user
            self.tableView.reloadData()
        }
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
