//
//  PopUpController.swift
//  urcal
//
//  Created by Kilian Hiestermann on 18.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit
import MapKit

class PopUpController: UIViewController{

    var longitude: Double?
    var latitude: Double?
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        mv.layer.cornerRadius = 10
        mv.clipsToBounds = true
        return mv
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
        
        setupMap()
    }
    
    func setupMap() {
        
        view.addSubview(mapView)
        mapView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 300)
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(closeButton)
        closeButton.anchor(top: mapView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: -32, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        closeButton.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        
        handleMapLocation(latitude: latitude!, longitude: longitude!)
        mapView.showsUserLocation = true
    }
    
    
    func handleMapLocation(latitude: Double, longitude: Double){
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.009, 0.009)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        let centerCoordinate = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
        annotation.coordinate = centerCoordinate
        annotation.title = "Title"
        
        mapView.addAnnotation(annotation)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)

    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}
