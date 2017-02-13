//
//  VCMapView.swift
//  HonoluluArt
//
//  Created by Abhijeet Mishra on 10/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import Foundation
import MapKit

extension ViewController:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Artwork {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            }
            else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier:identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x:-5, y:5)
                view.rightCalloutAccessoryView = UIButton.init(type:.detailDisclosure) as UIView
                view.pinColor = annotation.pinColor()
            }
            return view
        }
        return nil
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Artwork
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}
