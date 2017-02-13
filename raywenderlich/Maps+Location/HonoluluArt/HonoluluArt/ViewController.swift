//
//  ViewController.swift
//  HonoluluArt
//
//  Created by Abhijeet Mishra on 10/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
   
    let initialLocation = CLLocation(latitude:21.282778, longitude: -157.829444)
    
    let regionRadius:CLLocationDistance = 100
    
    var artworks = [Artwork]()
    
    var locationManager = CLLocationManager()
    
    func checkLoctionAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMapOnLocation(location: initialLocation)
        mapView.delegate = self
        
        loadInitialData()
        mapView.addAnnotations(artworks)
        
        //show artwork on map
        let artwork = Artwork(title:"King David Kalakaua", locationName:"Waikiki Gateway Park", discipline: "Sculpture", coordinate:CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661))
        mapView.addAnnotation(artwork)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLoctionAuthorizationStatus()
    }
    
    func loadInitialData() {
       
        if let theURL = Bundle.main.url(forResource: "PublicArt", withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as! [String:Any] {
                    let jsonData = JSONValue.fromObject(object: parsedData as AnyObject)
                    
                    print(jsonData!["data"]!.array!)
                    
                    for artworkJSON in jsonData!["data"]!.array! {
                      
                        let artworkJSON = artworkJSON.array
                        
                        if let artwork = Artwork.fromJSON(json: artworkJSON!) {
                            artworks.append(artwork)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    
    func centerMapOnLocation(location:CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
}

