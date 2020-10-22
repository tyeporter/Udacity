//
//  PhotoAlbumHeaderCell.swift
//  VirtualTourist
//
//  Created by Tye Porter on 6/1/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

protocol PhotoAlbumHeaderViewDelegate {
    func didEndEditingTitle(with text: String)
}

class PhotoAlbumHeaderView: UICollectionViewCell {
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        tf.textAlignment = NSTextAlignment.center
        return tf
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.systemBlue
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "dismiss"), for: UIControl.State.normal)
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.systemBlue
        return button
    }()
    
    var delegate: PhotoAlbumHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.textField.delegate = self
        
        self.addSubview(self.textField)
        self.textField.anchor(height: 25,
                              leftTo: self.leftAnchor,
                              rightTo: self.rightAnchor,
                              padLeft: 10, padRight: 10,
                              centerXTo: self.centerXAnchor,
                              centerYTo: self.centerYAnchor)
        
        self.addSubview(self.label)
        self.label.anchor(bottomTo: self.textField.topAnchor,
                          leftTo: self.leftAnchor,
                          rightTo: self.rightAnchor,
                          padBottom: 5, padLeft: 10, padRight: 10)
        
        self.addSubview(self.dismissButton)
        self.dismissButton.anchor(width: 20, height: 20,
                                  topTo: self.textField.bottomAnchor,
                                  padTop: 5,
                                  centerXTo: self.centerXAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UITextFieldDelegate
extension PhotoAlbumHeaderView: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
           self.delegate?.didEndEditingTitle(with: text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
