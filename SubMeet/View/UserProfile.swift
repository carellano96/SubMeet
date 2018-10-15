//
//  UserProfile.swift
//  SubMeet
//
//  Created by carlos arellano on 9/19/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit

class UserProfile: UIImageView {
    
    var username: String!
    var userID: String!
    var imageURL: String!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true;
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
