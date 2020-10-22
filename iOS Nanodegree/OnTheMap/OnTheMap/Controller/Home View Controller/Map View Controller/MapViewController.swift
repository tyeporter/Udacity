//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/11/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: Properties
    let mapView = MKMapView()
    var annotations = [MKPointAnnotation]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.brown
        self.mapView.delegate = self
        self.addAndAnchorSubviews()
    }
    
    // MARK: - Helper
    func setupAnnotationsForMap() {
        // Reset annotations
        self.mapView.removeAnnotations(annotations)
        annotations.removeAll()
        
        // For Each Student Location, Create an Annotation
        for studentLocation in StudentLocationModel.locations {
            let lat = CLLocationDegrees(studentLocation.latitude)
            let lon = CLLocationDegrees(studentLocation.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
            annotation.subtitle = studentLocation.mediaURL
            
            // Add annotation
            annotations.append(annotation)
        }
        
        // Add all annotations
        self.mapView.addAnnotations(annotations)
    }
    
    private func addAndAnchorSubviews() {
        self.view.addSubview(self.mapView)
        self.mapView.anchor(topTo: self.view.topAnchor,
                            bottomTo: self.view.bottomAnchor,
                            leftTo: self.view.leftAnchor,
                            rightTo: self.view.rightAnchor)
    }

}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = UIColor.udacityBlue
            pinView?.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            guard let urlString = view.annotation?.subtitle ?? "" else { return }
            guard let url = URL(string: urlString) else {
                print("unable to convert mediaURL string to URL")
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
