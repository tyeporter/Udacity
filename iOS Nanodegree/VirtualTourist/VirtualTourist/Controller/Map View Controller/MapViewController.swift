//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Tye Porter on 5/28/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit
import CoreData
import MapKit

fileprivate let reuseIdentifier = "pin"

class MapViewController: UIViewController {
    
    // MARK: Properties
    
    /// The `DataController` that allows us to interact with Core Data stack
    var dataController: DataController!
    /// Array that stores `Collection`s
    private var storedCollections: [Collection] = [] {
        didSet {
            if storedCollections.count > 0 {
                self.clearPinsButton.isEnabled = true
            } else {
                self.clearPinsButton.isEnabled = false
            }
        }
    }
    /// `Dictionary` that helps us keep track of which `Collection` each `MKPointAnnotation` belongs to
    private var annotationsDict: [MKPointAnnotation : NSManagedObjectID] = [:]
    
    // -------------------------------------------------------------------------
    
    /// An interactive `MKMapView` that shows user pins and allows user to drop new pins
    private let mapView = MKMapView()
    /// The `UIButton` that clears `mapView` of all collections
    private let clearPinsButton = ClearPinsButton()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        self.addAndAnchorSubviews()
        self.checkForSavedMapRegion()
        self.setupFetchResquest()
    }
        
    
    // MARK: - Actions / Events
    
    // TODO: Find a way to ignore Alert Controller auto layout constraint warnings
    
    /// This method presents a `UIAlertController` that allows the user to delete an `Image` from storage
    private func presentDeleteAlert() {
        // Instantiate alert controller
        let alertController = UIAlertController()
        alertController.title = "Delete Collections"
        alertController.message = "Are you sure you want to delete all collections?"

        // Create delete action
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) { (action) in
            // Delete `Collection`s from Core Data
            self.batchDeleteCollections()
           
            // Reset `storeCollection` array, reset tracker `Dictionary`, and remove all annotations from `mapView`
            self.storedCollections = []
            self.annotationsDict = [:]
            self.removeAllAnnotationsFromMapView(self.mapView.annotations)
        }
               
        // Creat dismiss action
        let dismissAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)

        // Add alert actions
        alertController.addAction(deleteAction)
        alertController.addAction(dismissAction)

        // Present controller
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func pressedClearPinsButton(_ sender: UIButton) {
        self.presentDeleteAlert()
    }
    
    // -------------------------------------------------------------------------
    
    /// This method handles long press gestures on `mapView`
    @objc func longPressedOnMapView(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            // Get point of gesture location
            let point = sender.location(in: self.mapView)
            // Get coordinate of area pressed
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            // Add new `Collection` -> `MKPointAnnoation`
            self.addCollection(coordinate)
        }
    }
    
    
    // MARK: - Helper
    
    /// This method adds a new `Collection` to Core Data
    private func addCollection(_ coordinate: CLLocationCoordinate2D) {
        // Instantiate `Collection` with `dataController` context
        let collection = Collection(context: self.dataController.viewContext)
        // Instantiate `Pin` with `dataController` context
        let pin = Pin(context: self.dataController.viewContext)
        // Set `collection`s `Pin`
        collection.pin = pin
        // Set `pin`'s `Collection
        pin.collection = collection
        // Set `pin`'s properties
        collection.pin!.latitude = coordinate.latitude
        collection.pin!.longitude = coordinate.longitude
        // Try to save context
        try? self.dataController.viewContext.save()
        // Append `collection` to `storedCollections` array
        self.storedCollections.append(collection)
        // Instatiate new `MKPointAnnotations`, set its coordinate, keep track of it, and add it to `mapView`
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.annotationsDict.updateValue(collection.pin!.objectID, forKey: annotation)
        self.mapView.addAnnotation(annotation)
    }
    
    private func removeAllAnnotationsFromMapView(_ annotations: [MKAnnotation]) {
        self.mapView.removeAnnotations(annotations)
    }
    
    /// This is a helper method that add stored `MKPointAnnotation`s to the controller's `mapView`
    private func setupAnnotationsForMap() {
        // For Each `Collection`, create an Annotation
        for collection in self.storedCollections {
            let lat = CLLocationDegrees(collection.pin!.latitude)
            let lon = CLLocationDegrees(collection.pin!.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            // Instantiate annotation and set its coordinate
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            // Add annotation to our "tracker" dictionary
            self.annotationsDict.updateValue(collection.pin!.objectID, forKey: annotation)
        }
        // Add all annotations to `mapView`
        let annotations = Array<MKPointAnnotation>(annotationsDict.keys)
        self.mapView.addAnnotations(annotations)
    }
    
     // -------------------------------------------------------------------------
    
    /// This is a helper method that batch deletes the entire Set `Collection`s in store
    private func batchDeleteCollections() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Collection")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
           
       do {
           try self.dataController.viewContext.execute(batchDeleteRequest)
       } catch {
           print("unsuccessful batch deleting the collections...")
       }
    }
    
    /// This helper method  sets up a fetch request for `Collection`,
    /// executes the fetch request, and stores the result in a variable
    private func setupFetchResquest() {
        // Instatiate fetch request
        let fetchRequest: NSFetchRequest<Collection> = Collection.fetchRequest()
        // Give the fetch request a sort descriptor
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // Try to fetch
        if let results = try? self.dataController.viewContext.fetch(fetchRequest) {
            self.storedCollections = results
            self.setupAnnotationsForMap()
        }
    }
    
    // -------------------------------------------------------------------------

    /// This is a helper method that saves map region to `UserDefaults`
    private func saveMapRegion() {
        // Covert `mapView`'s region to an array
        let regionArray = self.regionToArray(region: self.mapView.region)
        // Store region array in `UserDefaults`
        UserDefaults.standard.setValue(regionArray, forKey: "mapRegion")
    }
    
    /// This is a helper method that checks `UserDefaults` for saved map view region
    private func checkForSavedMapRegion() {
        if let regionArray = UserDefaults.standard.value(forKey: "mapRegion") as? [Double] { // If there is a saved map region...
            // Covert stored array to actual `MKCoordinateRegion`
            let region = self.arrayToRegion(regionArray: regionArray)
            // Set `mapView`'s region to stored region
            self.mapView.setRegion(region, animated: true)
        } else { // If there is no saved region
            // Covert `mapView`'s region to an array
            let regionArray = self.regionToArray(region: self.mapView.region)
            // Store region array in `UserDefaults`
            UserDefaults.standard.set(regionArray, forKey: "mapRegion")
        }
    }
    
    // -------------------------------------------------------------------------

    /// This method sets up the controller's subviews
    private func addAndAnchorSubviews() {
        // Map view
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressedOnMapView(_:)))
        longPressGesture.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longPressGesture)
        
        self.view.addSubview(self.mapView)
        self.mapView.anchor(topTo: self.view.topAnchor,
                            bottomTo: self.view.bottomAnchor,
                            leftTo: self.view.leftAnchor,
                            rightTo: self.view.rightAnchor)
        
        // Clear button
        self.clearPinsButton.layer.cornerRadius = 25
        self.clearPinsButton.addTarget(self, action: #selector(self.pressedClearPinsButton(_:)), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(self.clearPinsButton)
        self.clearPinsButton.anchor(width: 50, height: 50,
                               bottomTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                               rightTo: self.view.safeAreaLayoutGuide.rightAnchor,
                               padBottom: 20, padRight: 20)
        
    }
    
}


// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView?.pinTintColor = UIColor.red
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.mapView.deselectAnnotation(view.annotation, animated: true)
        // Retrieve `Collection` of annotation selected (This is why `annotationDict` is needed)
        let annotation = view.annotation as! MKPointAnnotation
        let selectedPin = dataController.viewContext.object(with: annotationsDict[annotation]!) as! Pin
        let selectedCollection = selectedPin.collection
        // Instantiate `PhotoAlbumViewController`
        let photoAlbumController = PhotoAlbumViewController()
        // Inject `photoAlbumController`'s dependencies
        photoAlbumController.dataController = self.dataController
        photoAlbumController.collection = selectedCollection
        // Present `photoAlbumController`
        self.present(photoAlbumController, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.saveMapRegion()
    }
    
}

// MARK: - User Defaults Helper
extension MapViewController {
    
    /// This helper method converts array with `MKCoordinateRegion` data to `MKCoordinateRegion`
    private func arrayToRegion(regionArray: [Double]) -> MKCoordinateRegion {
        let center = CLLocationCoordinate2D(latitude: regionArray[0], longitude: regionArray[1])
        let span = MKCoordinateSpan(latitudeDelta: regionArray[2], longitudeDelta: regionArray[3])
        return MKCoordinateRegion(center: center, span: span)
    }
    
    /// This helper method stores `MKCoordinateRegion` data in an array
    private func regionToArray(region: MKCoordinateRegion) -> [Double] {
        let array: [Double] = [region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta]
        return array
    }
    
}

