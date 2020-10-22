//
//  MemesTableViewController.swift
//  MemeMe
//
//  Created by Tye Porter on 4/11/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeTableCell"

class MemesTableViewController: UITableViewController {
    
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
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let unwrappedMemes = self.memes { return unwrappedMemes.count }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MemeTableViewCell
        cell.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.rgb(r: 27, g: 34, b: 39)
        cell.selectedBackgroundView = backgroundView
        
        if let meme = self.memes?[indexPath.row] {
            cell.memeTitle.text = meme.topText
            cell.memeSubtitle.text = meme.bottomText
            cell.memeImageView.image = meme.memedImage
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        self.selectedMemeIndex = indexPath.row
        self.selectedMeme = self.memes?[selectedMemeIndex]
        detailController.meme = self.selectedMeme
        detailController.delegate = self
        self.navigationController?.pushViewController(detailController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: UIContextualAction.Style.destructive, title: "Delete") { (action, view, completionHandler) in
            
            // Delete meme from App Delegate
            let object = UIApplication.shared.delegate
            let appDelegate = object as? AppDelegate
            if let unwrappedAppDelegate = appDelegate { unwrappedAppDelegate.memes.remove(at: indexPath.row) }
            
            // Remove row
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)

            completionHandler(true)
        }
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [delete])
        return swipeConfig
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
    
}

// MARK: - MemeMakerViewControllerDelegate

extension MemesTableViewController: MemeMakerViewControllerDelegate {
    
    func memeMakerController(_ memeMakerController: MemeMakerViewController, didAddMemeWithObject meme: Meme) {
        self.tableView.reloadData()
    }
    
    func memeMakerController(_ memeMakerController: MemeMakerViewController, didFinishEditingWithObject meme: Meme) {
        // Remove the old meme and insert the new meme
        let object = UIApplication.shared.delegate
        let appDelegate = object as? AppDelegate
        if let unwrappedAppDelegate = appDelegate {
            unwrappedAppDelegate.memes.remove(at: selectedMemeIndex)
            unwrappedAppDelegate.memes.insert(meme, at: selectedMemeIndex)
        }
        self.tableView.reloadData()
    }
    
}

extension MemesTableViewController: MemeDetailViewControllerDelegate {
    
    func memeDetailController(_ memeDetailController: MemeDetailViewController, willEditMemeWithObject: Meme) {
        self.presentMemeMakerControllerInEditMode(forMemeAt: selectedMemeIndex)
    }
    
}

