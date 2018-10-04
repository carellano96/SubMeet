//
//  CellNotificationView.swift
//  SubMeet
//
//  Created by carlos arellano on 10/1/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit

class CellNotificationView: UIView {
    @IBOutlet weak var NotificationNumber: UILabel!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true;    }
 

}
