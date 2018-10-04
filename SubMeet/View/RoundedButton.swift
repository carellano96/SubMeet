//
//  RoundedButton.swift
//  SubMeet
//
//  Created by carlos arellano on 9/26/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    
    
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
    

}
