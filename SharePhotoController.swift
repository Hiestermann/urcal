//
//  SharePhotoController.swift
//  urcal
//
//  Created by Kilian Hiestermann on 09.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class SharePhotoController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate{
        
    let manager = CLLocationManager()
    var locality: String?
    
    var longitude: Double?
    var latitude: Double?
    
   var selectedImage: UIImage? {
        didSet{
            
            imageView.image = selectedImage
        }
    }
    
    let captionView: UIView = {
        let view = UIView()
        return view
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
   lazy var textView: UITextField = {
        let tf = UITextField()
        tf.text = "Thats awsome!"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
        
    }()
    
    let searchOnMapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search on Map", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSearchOnMap), for: .touchUpInside)
        return button
    }()
    
    func handleSearchOnMap() {
        let searchOnMapViewController = SearchOnMapViewController()
        navigationController?.pushViewController(searchOnMapViewController, animated: true)
    }
    
    var map: MKMapView = {
        let mapView = MKMapView()
        mapView.isZoomEnabled = true
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "share", style: .plain, target: self, action: #selector(handleShare))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAnnotation), name: .sendAnnoitation, object: nil)
        
        setupImageAndTextView()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
        
    }
    
    func handleAnnotation(notification : Notification) {
        let annoitation = notification.object as? [MKAnnotation]
        
        guard let location = annoitation?[0].coordinate else { return }
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)

        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        map.setRegion(region, animated: true)
        map.addAnnotations(annoitation!)
        
        self.latitude = location.latitude
        self.longitude = location.longitude
        handleFetchLocality(coordinats: location)
    }
    
    fileprivate func handleLocationAndAnnoitation(map: MKMapView, coordinate: CLLocationCoordinate2D, annoitation: MKAnnotation = MKPointAnnotation()){
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location.coordinate, span)
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        let centerCoordinate = location.coordinate
        annotation.coordinate = centerCoordinate
        annotation.title = "Title"
        
        map.addAnnotation(annotation)
        manager.stopUpdatingLocation()
        
         handleFetchLocality(coordinats: location.coordinate)
        
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude

    }
    
    func handleFetchLocality(coordinats: CLLocationCoordinate2D){
       
        let location = CLLocation(latitude: coordinats.latitude, longitude: coordinats.longitude)
                
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                guard let pm = placemarks?[0].locality else { return }
                self.locality = pm
            }else {
                print("Problem with the data received from geocoder")
            }
        })
        
    }

    
    override var prefersStatusBarHidden: Bool{
        return true
    }
  
    
    func setupImageAndTextView(){
        
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width/2, height: view.frame.width/2)
        
        view.addSubview(map)
        map.anchor(top: view.topAnchor, left: imageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width/2, height: view.frame.width/2)
        
        view.addSubview(searchOnMapButton)
        searchOnMapButton.anchor(top: map.bottomAnchor, left: map.leftAnchor, bottom: nil, right: map.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
      
        view.addSubview(textView)
        textView.anchor(top: searchOnMapButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: 0, height: 40)
                
    }
    
    func handleShare() {
        
        guard let image = imageView.image else { return }
        guard let uplaodData = UIImageJPEGRepresentation(image, 0.2) else { return }
        let geoImage = getGeoImage()
        guard let uploadGeoImage = UIImageJPEGRepresentation(geoImage, 1) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let postFilename = NSUUID().uuidString
        let geoFileName = NSUUID().uuidString
        guard let uId = FIRAuth.auth()?.currentUser?.uid else { return }
         FIRStorage.storage().reference().child("post").child(uId).child("postImage").child(postFilename).put(uplaodData, metadata: nil) { (metadata, err) in
            if let err = err {
                print(err)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            guard let imageName = metadata?.name else { return }
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
            FIRStorage.storage().reference().child("post").child(uId).child("geoImage").child(geoFileName).put(uploadGeoImage, metadata: nil, completion: { (metadata, err) in
                if let err = err {
                    print(err)
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    return
                }
                
                guard let geoImageName = metadata?.name else { return }
                guard let geoImageURL = metadata?.downloadURL()?.absoluteString else { return }
                
                self.saveToDataBaseWithImageUrl(imageUrl: imageUrl, imageName: imageName, geoImageURL: geoImageURL, geoImageName: geoImageName)
            })
            
        }
    }

    
    func saveToDataBaseWithImageUrl(imageUrl: String, imageName: String, geoImageURL: String, geoImageName: String) {
        
        guard let userLocality = locality else { return }
        guard let user = FIRAuth.auth()?.currentUser?.uid else { return }
        guard let postImage = selectedImage else { return }
        guard let captionText = textView.text else { return }
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let userPostRef = FIRDatabase.database().reference().child("posts")
        let ref =  userPostRef.childByAutoId()
        guard  let longitude = self.longitude else { return }
        guard let latitude = self.latitude else { return }
        let postId = ref.key
        
        let values = ["uid": user, "imageUrl": imageUrl, "text": captionText, "imageWidth": postImage.size.width, "imageSize": postImage.size.height, "creationDate": Date().timeIntervalSince1970, "user": user, "longitude": longitude, "latitude": latitude, "postId": postId, "imageName": imageName, "geoImageUrl": geoImageURL, "geoImageName": geoImageName] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print(err)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            let localityRef = FIRDatabase.database().reference().child("localities").child(userLocality)
            let postId = ref.key
            localityRef.updateChildValues([postId: 1])
            
            let userRef =  FIRDatabase.database().reference().child("users").child(uid).child("posts")
            userRef.updateChildValues([postId: 1])
            
            NotificationCenter.default.post(name: .refreshHomeController , object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                
            } else {
             //   self.view.frame.origin.y -= 150
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    func getGeoImage() -> UIImage {
    
        UIGraphicsBeginImageContextWithOptions(map.frame.size, true, 0.0)
        map.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }

}
