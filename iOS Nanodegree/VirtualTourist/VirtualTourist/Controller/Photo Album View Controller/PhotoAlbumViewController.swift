//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Tye Porter on 5/29/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit
import CoreData

fileprivate let reuseIdentifier = "PhotoCollectionViewCell"

class PhotoAlbumViewController: UIViewController {
    
    // MARK: Properties

    /// The `DataController` that allows us to interact with Core Data stack
    var dataController: DataController!
    /// The `Collection` for this controller
    var collection: Collection!
    /// Array that stores `Images`s
    private var storedImages: [Image] = []
    
    // -------------------------------------------------------------------------
    
    /// `UICollectionViewController` whose purpose it to show stored images
    private let collectionViewController = UICollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    /// `UIToolbar` that allows user to fetch a new collection of images
    private let toolbar = UIToolbar()
    /// `UIView` that conveys to the user that there are no images
    private let noImagesOverlayView = NoImagesOverlayView()
    
    // -------------------------------------------------------------------------

    /// A date formatter for date text in note cells
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.medium
        return df
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.collectionViewController.collectionView.backgroundColor = UIColor.white
        self.collectionViewController.collectionView.delegate = self
        self.collectionViewController.collectionView.dataSource = self
        self.collectionViewController.collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.addAndAnchorSubviews()
        self.setupFetchRequest()
    }
    
    
    // MARK: - Actions / Events
    
    // TODO: Find a way to ignore Alert Controller auto layout constraint warnings
    
    /// This method presents a `UIAlertController` that allows the user to delete an `Image` from storage
    private func presentDeleteAlert(with collectionViewCell: UICollectionViewCell, indexPath: IndexPath) {
        // Instantiate alert controller
        let alertController = UIAlertController()
        alertController.title = "Delete Image"
        alertController.message = "Are you sure you want to delete this image?"

        // Create delete action
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) { (action) in
            // Delete `Image` from Core Data
            let imageToDelete = self.image(at: indexPath)
            self.dataController.viewContext.delete(imageToDelete)
            try? self.dataController.viewContext.save()
           
            // Remove `Image` from `storeImages` array and from `collectionViewController`'s `collectionView`
            self.storedImages.remove(at: indexPath.item)
            self.collectionViewController.collectionView.deleteItems(at: [indexPath])
        }
               
        // Creat dismiss action
        let dismissAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)

        // Add alert actions
        alertController.addAction(deleteAction)
        alertController.addAction(dismissAction)

        // Present controller
        present(alertController, animated: true, completion: nil)
    }
    
    /// This method handles long press gestures on `collectionViewController`'s `collectionView`
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer!) {
        if gesture.state == UIGestureRecognizer.State.began {
            // Get point of gesture location
            let point = gesture.location(in: self.collectionViewController.collectionView)
            // Get `indexPath` of cell pressed
            if let indexPath = self.collectionViewController.collectionView.indexPathForItem(at: point) {
                // Get the cell at indexPath (the one you long pressed)
                guard let cell = self.collectionViewController.collectionView.cellForItem(at: indexPath) else { return }
                // Present delete alert
                self.presentDeleteAlert(with: cell, indexPath: indexPath)
            } else { print("couldn't find index path") }
        }
    }
    
    // -------------------------------------------------------------------------
    
    /// This method adds a new `Image` to `collection`
    private func addImage(_ photo: PhotoCodable) {
        // Instatiate `Image` with `dataController` context
        let image = Image(context: self.dataController.viewContext)
        // Set `images` properties
        image.farm = "\(photo.farm)"
        image.server = photo.server
        image.id = photo.id
        image.secret = photo.secret
        // Set `image`s `Collection`
        image.collection = self.collection
        // Try to save context
        try? self.dataController.viewContext.save()
        // Append `image` to `storedImages` array
        self.storedImages.append(image)
    }
    
    /// This method is the comption handler for `FlickrClient`s `getPhotosForPlace` method
    /// It handles the results we get back from the network call
    private func handleGetPhotosForPlace(photos: [PhotoCodable], error: Error?) {
        guard error == nil else {
            print("unsuccessful getting image for place...")
            return
        }
        
        if photos.count == 0 { // If there are no photos for this location...
            // Show overlay view
            self.noImagesOverlayView.alpha = 1
        } else { // If there are photos for this location
            // Hide overlay view
            self.noImagesOverlayView.alpha = 0
            // Add each photo to Core Data
            for photo in photos { self.addImage(photo) }
            // Reload collection view
            self.collectionViewController.collectionView.reloadData()
            // Enable new collection button
            self.toolbar.items![1].isEnabled = true
        }
    }
    
    private func addNewCollection() {
        // Disable new collection button
        self.toolbar.items![1].isEnabled = false
        // Get photos for location
        FlickrClient.getPhotosForPlace(latitude: self.collection.pin!.latitude, longitude: self.collection.pin!.longitude, keyword: "scenery", completionHandler: self.handleGetPhotosForPlace(photos:error:))
    }
    
    @objc private func newCollectionButtonPressed(_ sender: Any) {
        // Empty `storedImages` array
        self.storedImages = []
        // Batch delete `Image`s from Core Data
        self.batchDeleteImages()
        // Save context
        try? self.dataController.viewContext.save()
        // Add new collection
        self.addNewCollection()
    }
    
    // -------------------------------------------------------------------------
    
    @objc private func dismissButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Helper
    
    /// This is a helper method that batch deletes the entire Set `Image`s in this `Collection`
    private func batchDeleteImages() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        let predicate = NSPredicate(format: "collection == %@", self.collection)
        fetchRequest.predicate = predicate
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.dataController.viewContext.execute(batchDeleteRequest)
        } catch {
            print("unsuccessful batch deleting the images...")
        }
    }
    
    /// This is a helper method that checks if there are `Image`s stored in the `Collection`
    private func checkIfCollectionHasImages() {
        if self.storedImages.count == 0 { // If there are no stored `Images`s...
            // Add a new collection
            self.addNewCollection()
        } else { // If there are stored images...
            // Enable new collection button
            self.toolbar.items![1].isEnabled = true
        }
    }
    
    /// This is a helper method that sets up a fetch request for `Image` of this `Collection`,
    /// executes the fetch request, and stores the result in a variable
    private func setupFetchRequest() {
        // Instatiate fetch request
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        // Give the fetch request a predicate
        let predicate = NSPredicate(format: "collection == %@", self.collection)
        fetchRequest.predicate = predicate
        // Try to fetch
        if let result = try? self.dataController.viewContext.fetch(fetchRequest) {
            self.storedImages = result
            self.checkIfCollectionHasImages()
            self.collectionViewController.collectionView.reloadData()
        }
    }
    
    // -------------------------------------------------------------------------
    
    /// This helper method returns the `Image` associated with an `IndexPath`
    private func image(at indexPath: IndexPath) -> Image {
        return self.storedImages[indexPath.item]
    }
    
    // -------------------------------------------------------------------------
    
    // TODO: Find a way to ignore Toolbar auto layout constraint warnings
    
    /// This method sets up the controller's subviews
    private func addAndAnchorSubviews() {
        
        // Toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        self.toolbar.setItems([
            flexibleSpace,
            UIBarButtonItem(title: "New Collection", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.newCollectionButtonPressed(_:))),
            flexibleSpace,
        ], animated: true)
        
        self.toolbar.items![1].isEnabled = false
        
        self.view.addSubview(self.toolbar)
        self.toolbar.anchor(bottomTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                            leftTo: self.view.leftAnchor,
                            rightTo: self.view.rightAnchor)
        
        // Header
        let headerView = PhotoAlbumHeaderView()
        
        if let creationDate = self.collection.creationDate {
            headerView.label.text = dateFormatter.string(from: creationDate)
        }
        headerView.delegate = self
        headerView.textField.placeholder = "Title"
        headerView.textField.text = self.collection.name
        headerView.dismissButton.addTarget(self, action: #selector(self.dismissButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(headerView)
        headerView.anchor(height: 100,
                          topTo: self.view.safeAreaLayoutGuide.topAnchor,
                          leftTo: self.view.safeAreaLayoutGuide.leftAnchor,
                          rightTo: self.view.safeAreaLayoutGuide.rightAnchor)
        
        // Collection view
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        self.collectionViewController.collectionView.addGestureRecognizer(longPressGesture)
        
        self.view.addSubview(self.collectionViewController.collectionView)
        self.collectionViewController.collectionView.anchor(topTo: headerView.bottomAnchor,
                                   bottomTo: toolbar.topAnchor,
                                   leftTo: self.view.safeAreaLayoutGuide.leftAnchor,
                                   rightTo: self.view.safeAreaLayoutGuide.rightAnchor)
        
        // Overlay view
        self.noImagesOverlayView.alpha = 0
        self.noImagesOverlayView.dismissButton.addTarget(self, action: #selector(self.dismissButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(self.noImagesOverlayView)
        self.noImagesOverlayView.anchor(topTo: self.view.safeAreaLayoutGuide.topAnchor,
                                        bottomTo: toolbar.topAnchor,
                                        leftTo: self.view.safeAreaLayoutGuide.leftAnchor,
                                        rightTo: self.view.safeAreaLayoutGuide.rightAnchor)
    }
    
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.storedImages.count > 0 ? self.storedImages.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        // Get image associated with `indexPath`
        let image = self.image(at: indexPath)
        // Download image
        FlickrClient.downloadPhoto(farm: image.farm!, server: image.server!, id: image.id!, secret: image.secret!) { (image: UIImage?, error: Error?) in
            if image != nil {
                // Set `cell`'s `image`
                cell.image = image
            }
        }
        return cell
    }
    
    // Flow layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.orientation.isLandscape {
            let width = (self.view.frame.width - 6) / 8
            return CGSize(width: width, height: width)
        } else {
            let width = (self.view.frame.width - 10) / 3
            return CGSize(width: width, height: width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}

// MARK: - PhotoAlbumHeaderViewDelegate
extension PhotoAlbumViewController: PhotoAlbumHeaderViewDelegate {
    
    func didEndEditingTitle(with text: String) {
        // Set `collection`'s `name` property
        self.collection.name = text
        // Try saving `dataController`'s context
        try? self.dataController.viewContext.save()
    }
        
}
