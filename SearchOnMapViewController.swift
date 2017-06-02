//
//  SearchOnMapViewController.swift
//  urcal
//
//  Created by Kilian Hiestermann on 27.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit
import MapKit

class SearchOnMapViewController: UIViewController, UISearchControllerDelegate,UISearchBarDelegate,MKMapViewDelegate, UISearchResultsUpdating {
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {
        
    }


    let locationManager = CLLocationManager()
    
    var resultSearchController:UISearchController!
    
    var map: MKMapView = {
        let mv = MKMapView()
        return mv
    }()
    
    lazy var choseAnnoitation: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        button.setTitle("Chose Location", for: .normal)
        button.addTarget(self, action: #selector(handleGeoView), for: .touchUpInside)
        return button
    }()
    
    func handleGeoView() {
        NotificationCenter.default.post(name: .sendAnnoitation, object: map.annotations)
        self.navigationController?.popViewController(animated: true)
    }
    
    var locationSearchTable: LocationSearchTable!
    
    var matchingItems:[MKMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        view.addSubview(choseAnnoitation)
        choseAnnoitation.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
        
        view.addSubview(map)
        map.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: choseAnnoitation.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        

        
        locationSearchTable = LocationSearchTable()
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = self
        
        let searchBar = resultSearchController!.searchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        resultSearchController?.searchResultsController?.reloadInputViews()
        definesPresentationContext = true
        map.showsUserLocation = true
        locationSearchTable.matchingItems = matchingItems
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAnnoitation), name: .createAnnotation, object: nil)
    }
    
    func handleAnnoitation(notification: Notification) {
        let placeMark = notification.object as! MKPlacemark
        let annotation = MKPointAnnotation()
        annotation.coordinate = placeMark.coordinate
        annotation.title = placeMark.title
        map.addAnnotations([annotation])
    }
    
    func handleMapResults(searchText: String) {
        // guard let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
         request.naturalLanguageQuery = searchText
        request.region = map.region
        let search = MKLocalSearch(request: request)
        search.start { (response, err) in
            if err != nil{
                return
            }
            self.matchingItems = (response?.mapItems)!
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        handleMapResults(searchText: searchText)
        
        NotificationCenter.default.post(name: .refreshResults, object: self.matchingItems)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            map.setRegion(region, animated: true)
        }
    }
}


extension SearchOnMapViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            print("location:: (location)")
        }
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
}
