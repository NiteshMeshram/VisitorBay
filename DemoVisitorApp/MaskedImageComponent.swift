//
//  MaskedImageComponent.swift
//  DemoCollectionView
//
//  Created by Nitesh Meshram on 23/10/18.
//  Copyright © 2018 Nitesh Meshram. All rights reserved.
//

import Foundation
import UIKit

class MaskedImageComponent: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.circleImage()
    }
    
    func circleImage() -> Void {
        
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.circleImage()
        
    }
    
}
