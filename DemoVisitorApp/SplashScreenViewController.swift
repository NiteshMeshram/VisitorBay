
//
//  SplashScreenViewController.swift
//  DemoVisitorApp
//
//  Created by Nitesh Meshram on 31/07/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import UIKit
class SplashScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("landscape")
        } else {
            print("portrait")
        }
    }
}
