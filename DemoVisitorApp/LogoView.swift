//
//  LogoView.swift
//  DemoVisitorApp
//
//  Created by Nitesh Meshram on 29/12/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import UIKit

class LogoView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    private func commonInit(){
        
    }

}
