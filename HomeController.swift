//
//  HomeController.swift
//  urcal
//
//  Created by Kilian Hiestermann on 12.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    let cellId = "cellId"
    var locality: String?{
        didSet{
            navigationItem.title = locality
        }
    }
    var userBookmarks = [String]()
    
    var posts = [UserPost]()
    
    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        collectionView?.register(HomeControllerViewCell.self, forCellWithReuseIdentifier: cellId)
        
        //refresh if the user pulls down the screen
        let refreshContoll = UIRefreshControl()
        refreshContoll.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshContoll
        
        
        // refresh the HomeController if the user shares a new post
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name:.refreshHomeController, object: nil)
        
        // Notification to show the View of the Map
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowMap), name: .setUpMap, object: nil)
        
        if locality == nil {
            settingUpCLLocationManager()

        }
        
        handleRefresh()
    }
    
    fileprivate func settingUpCLLocationManager(){
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
    
    }
    
    func handleShowMap(notification: Notification){
        
        if let myDict = notification.object as? [String: Any]{
            if let longitude = myDict["longitude"] as? Double {
                if let latitude = myDict["latitude"] as? Double {
                    let popUpController = PopUpController()
                    popUpController.longitude = longitude
                    popUpController.latitude = latitude
                    popUpController.modalPresentationStyle = .overCurrentContext
                    present(popUpController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func handleRefresh (){
        posts.removeAll()
        userBookmarks.removeAll()
        collectionView?.reloadData()    
        fetchBookmarks()
        fetchLocalityPosts()    
    }
    
    
    // setting up cells
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeControllerViewCell
        cell.userLatitude = manager.location?.coordinate.latitude
        cell.userLongitude = manager.location?.coordinate.longitude
        if userBookmarks.contains(posts[indexPath.item].post.postId){
            cell.bookmarked = true
        } else {
            cell.bookmarked = false

        }
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // height is widht of the frame + top View + logos + logo labels + paddings top and botton
        let height = (view.frame.width / 2) + 60 + 32 + 14 + 12
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    
    fileprivate func fetchLocalityPosts(){
        guard let localityPosts = locality else { return }
        FIRDatabase.database().reference().child("localities").child(localityPosts).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let postIdDictionary = snapshot.value as? [String: Any] else { return }
            self.collectionView?.refreshControl?.endRefreshing()
           postIdDictionary.forEach({ (key, value) in
            FIRDatabase.fetchPostWithId(postId: key, completion: { (post) in
                FIRDatabase.fetchUserWithUid(uid: post.uid, completion: { (user) in
                    let fetchdpost = UserPost(user: user, post: post)
                    self.posts.append(fetchdpost)
                    
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.post.creationDate.compare(p2.post.creationDate) == .orderedDescending
                    })
                    self.collectionView?.reloadData()

                })
            })
           })
        }) { (err) in
            print(err)
        }
    }
    
    fileprivate func fetchBookmarks(){
        guard let uId = FIRAuth.auth()?.currentUser?.uid else { return }
        let ref = FIRDatabase.database().reference().child("users").child(uId).child("bookmarks")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let postIdDictionary = snapshot.value as? [String: Any] else { return }
            postIdDictionary.forEach({ (key, value) in
                self.userBookmarks.append(key)
            })
            
        }) { (err) in
            print(err)
        }
    
    }
    
//    fileprivate func fetchFollowingUserIds() {
//        let uid = FIRAuth.auth()?.currentUser?.uid
//        FIRDatabase.database().reference().child("following").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
//            
//            userIdsDictionary.forEach({ (key, value) in
//                FIRDatabase.fetchUserWithUid(uid: key, completion: { (user) in
//                    self.fetchPostWithUsername(user: user)
//                })
//            })
//            
//            
//        }) { (err) in
//            print(err)
//        }
//        
//    }
//    
//    // getting the Post from Firebase
//    fileprivate func fetchPostWithUsername(user: User) {
//        
//        guard let userLocality = locality else { return }
//        let ref = FIRDatabase.database().reference().child("post").child(userLocality).child(user.uid)
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//       
//            self.collectionView?.refreshControl?.endRefreshing()
//            
//            guard let dictionarys = snapshot.value as? [String: Any] else { return }
//            
//            dictionarys.forEach({ (key, value) in
//                
//                guard let dictionary = value as? [String: Any] else { return }
//                let post = UserPost(user: user, dictionary: dictionary)
//                self.posts.append(post)
//            })
//            
//            self.posts.sort(by: { (p1, p2) -> Bool in
//                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
//            })
//            self.collectionView?.reloadData()
//            
//        }) { (err) in
//            print("Faild to fetch entire Data", err)
//        }
//    }
    
    // get the locality from the user
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
       
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), completionHandler: {(placemarks, err) -> Void in
                                                
        if err != nil {
            print("Reverse geocoder failed with error" + err!.localizedDescription)
          return
        }
                                                
            if placemarks!.count > 0 {
                let pm = placemarks?[0].locality
                self.navigationItem.title = pm
                self.locality = pm
                manager.stopUpdatingLocation()
                
            }else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
}
