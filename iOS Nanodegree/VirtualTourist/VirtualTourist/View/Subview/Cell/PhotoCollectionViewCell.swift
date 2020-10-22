//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Tye Porter on 6/1/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
            self.setFetchingPhoto(false)
        }
    }
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = UIView.ContentMode.scaleAspectFill
        return iv
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.alpha = 1
        return view
    }()
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setFetchingPhoto(true)
        self.addSubview(self.imageView)
        self.imageView.anchor(topTo: self.topAnchor,
                              bottomTo: self.bottomAnchor,
                              leftTo: self.leftAnchor,
                              rightTo: self.rightAnchor)
        
        self.addSubview(self.overlayView)
        self.overlayView.addSubview(self.activityIndicator)
        self.overlayView.anchor(topTo: self.topAnchor,
                                bottomTo: self.bottomAnchor,
                                leftTo: self.leftAnchor,
                                rightTo: self.rightAnchor)
        self.activityIndicator.anchor(centerXTo: self.overlayView.centerXAnchor,
                                      centerYTo: self.overlayView.centerYAnchor)
        self.overlayView.isHidden = false
    }
    
    private func setFetchingPhoto(_ fetchingPhoto: Bool) {
        if fetchingPhoto { // Controller is Fetching Photos...
            self.overlayView.isHidden = false
            self.activityIndicator.startAnimating()
        } else {
            self.overlayView.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
