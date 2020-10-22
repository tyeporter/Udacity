//
//  EditActivity.swift
//  MemeMe
//
//  Created by Tye Porter on 4/17/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit

// UIActivityViewController By Example (https://www.hackingwithswift.com/articles/118/uiactivityviewcontroller-by-example)

class EditActivity: UIActivity {
    
    var _activityTitle: String
    var _activityImage: UIImage?
    var activityItems = [Any]()
    var action: ([Any]) -> Void
    
    init(title: String, image: UIImage?, performingAction: @escaping ([Any]) -> Void) {
        self._activityTitle = title
        self._activityImage = image
        self.action = performingAction
        super.init()
    }
    
    override var activityTitle: String? {
        return self._activityTitle
    }
    
    override var activityImage: UIImage? {
        return self._activityImage
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: "io.github.tyeporter.MemeMe.EditActivity")
    }
    
    override class var activityCategory: UIActivity.Category {
        return UIActivity.Category.action
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        self.activityItems = activityItems
    }
    
    override func perform() {
        self.action(activityItems)
        self.activityDidFinish(true)
    }
    
}
