//
//  CommentCell.swift
//  SubMeet
//
//  Created by Carlos Arellano on 10/1/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import FirebaseStorage
class CommentCell: UITableViewCell {
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var CommentLabel: UILabel!
    @IBOutlet weak var ConnectImage: UIImageView!
    @IBOutlet weak var Notification: CellNotificationView!
    var connect: Connect!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

