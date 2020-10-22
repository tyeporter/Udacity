//
//  MemesCollectionViewController.swift
//  MemeMe
//
//  Created by Tye Porter on 4/11/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeCollectionCell"

class MemesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    
    var memes: [Meme]? {
        let object = UIApplication.shared.delegate
        guard let appDelegate = object as? AppDelegate else { return [Meme]() }
        return appDelegate.memes
    }
    var selectedMeme: Meme?
    var selectedMemeIndex: Int = 0
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (_) in
            self.collectionViewLayout.invalidateLayout()
        }) { (_) in }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let unwrappedMemes = self.memes { return unwrappedMemes.count }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
        
        if let meme = self.memes?[(indexPath as NSIndexPath).row] {
            cell.memeImageView.image = meme.memedImage
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        self.selectedMemeIndex = indexPath.item
        self.selectedMeme = self.memes?[selectedMemeIndex]
        detailController.meme = selectedMeme
        detailController.delegate = self
        self.navigationController?.pushViewController(detailController, animated: true)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.orientation.isLandscape {
            let width = (self.view.frame.width - 6) / 8
            return CGSize(width: width, height: width)
        } else {
            let width = (self.view.frame.width - 3) / 4
            return CGSize(width: width, height: width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: Actions
    
    @IBAction func presentMemeMakerController(_ sender: Any) {
        let memeMakerVC: MemeMakerViewController
        memeMakerVC = storyboard?.instantiateViewController(withIdentifier: "MemeMakerViewController") as! MemeMakerViewController
        memeMakerVC.delegate = self
        present(memeMakerVC, animated: true, completion: nil)
    }
    
    func presentMemeMakerControllerInEditMode(forMemeAt index: Int) {
        let memeMakerVC: MemeMakerViewController
        memeMakerVC = storyboard?.instantiateViewController(withIdentifier: "MemeMakerViewController") as! MemeMakerViewController
        memeMakerVC.delegate = self
        memeMakerVC.editingMeme = self.memes?[index]
        memeMakerVC.isEditingMeme = true
        present(memeMakerVC, animated: true, completion: nil)
    }
    
    @IBAction func handleLongPress(_ gesture: UILongPressGestureRecognizer!) {
        if gesture.state == .began {
            print("Long press")
            let point = gesture.location(in: self.collectionView)

            if let indexPath = self.collectionView.indexPathForItem(at: point) {
                // get the cell at indexPath (the one you long pressed)
                guard let cell = self.collectionView.cellForItem(at: indexPath) else { return }
                
                self.presentDeleteAlert(with: cell, indexPath: indexPath)
            } else {
                print("couldn't find index path")
            }
        }
    }
    
    func presentDeleteAlert(with collectionViewCell: UICollectionViewCell, indexPath: IndexPath) {
        let alertController = UIAlertController()
        alertController.title = "Delete Meme"
        alertController.message = "Are you sure you want to delete this meme?"
        
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) { (action) in
            
            // Delete meme from App Delegate
            let object = UIApplication.shared.delegate
            let appDelegate = object as? AppDelegate
            if let unwrappedAppDelegate = appDelegate { unwrappedAppDelegate.memes.remove(at: indexPath.item) }
            
            // Remove item
            self.collectionView.deleteItems(at: [indexPath])
            
            self.dismiss(animated: true, completion: nil)
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - MemeMakerViewControllerDelegate

extension MemesCollectionViewController: MemeMakerViewControllerDelegate {
    
    func memeMakerController(_ memeMakerController: MemeMakerViewController, didAddMemeWithObject meme: Meme) {
        self.collectionView.reloadData()
    }
    
    func memeMakerController(_ memeMakerController: MemeMakerViewController, didFinishEditingWithObject meme: Meme) {
        // Remove the old meme and insert the new meme
        let object = UIApplication.shared.delegate
        let appDelegate = object as? AppDelegate
        if let unwrappedAppDelegate = appDelegate {
            unwrappedAppDelegate.memes.remove(at: selectedMemeIndex)
            unwrappedAppDelegate.memes.insert(meme, at: selectedMemeIndex)
        }
        self.collectionView.reloadData()
    }
    
}

// MARK: - MemeDetailViewControllerDelegate
extension MemesCollectionViewController: MemeDetailViewControllerDelegate {
    
    func memeDetailController(_ memeDetailController: MemeDetailViewController, willEditMemeWithObject: Meme) {
        self.presentMemeMakerControllerInEditMode(forMemeAt: selectedMemeIndex)
    }
    
}
