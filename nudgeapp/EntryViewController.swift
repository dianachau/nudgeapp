//
//  EntryViewController.swift
//  nudgeapp
//
//  Created by Diana on 8/31/16.
//  Copyright © 2016 diana. All rights reserved.
//

import UIKit
import CoreMotion
import CoreData

class EntryViewController: UIViewController {

    // MARK: - CM Device Motion Manager
    let manager = CMMotionManager()
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        entryTextView.isFirstResponder()
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.02
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMDeviceMotion?, error: NSError?) in
                
                if data?.userAcceleration.x < -2.5 {
                    self?.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }

    
    
    
    // MARK: - Outlets
    @IBOutlet weak var entryTextView: UITextView!

    
}




