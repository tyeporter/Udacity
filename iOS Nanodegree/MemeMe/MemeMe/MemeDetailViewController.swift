//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Tye Porter on 4/16/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

protocol MemeDetailViewControllerDelegate: AnyObject {
    func memeDetailController(_ memeDetailController: MemeDetailViewController, willEditMemeWithObject: Meme)
}

class MemeDetailViewController: UIViewController {
    
    // MARK: Properties

    @IBOutlet weak var memeImageView: UIImageView!
    var meme: Meme!
    var delegate: MemeDetailViewControllerDelegate?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.isHidden = true
        self.memeImageView.image = self.meme?.memedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: Actions
    
    @IBAction func editMeme(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.delegate?.memeDetailController(self, willEditMemeWithObject: meme)
    }
    
    // TODO: Combined both gesture recognizers for a more smooth user experience
    
    // Using Gesture Recognizers (guides.codepath.com/ios/Using-Gesture-Recognizers#add-and-configure-a-gesture-recognizer-in-storyboard)
    
    @IBAction func didPinch(_ sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        if let imageView = sender.view as? UIImageView {
            imageView.transform = imageView.transform.scaledBy(x: scale, y: scale)
            sender.scale = 1
        }
    }
    
    @IBAction func didRotate(_ sender: UIRotationGestureRecognizer) {
        let rotation = sender.rotation
        if let imageView = sender.view as? UIImageView {
            imageView.transform = imageView.transform.rotated(by: rotation)
            sender.rotation = 0
        }
    }

}
