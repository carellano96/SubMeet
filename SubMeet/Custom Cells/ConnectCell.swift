//
//  ConnectCell.swift
//  SubMeet
//
//  Created by carlos arellano on 9/29/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import FirebaseStorage
class ConnectCell: UITableViewCell {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var MessageLabel: UILabel!
    @IBOutlet weak var ConnectImage: UIImageView!
    @IBOutlet weak var Notification: CellNotificationView!
    var connect: Connect!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configCell(connect: Connect){
        Notification.isHidden = true
        MessageLabel.font = UIFont.systemFont(ofSize: 17)
        self.connect = connect
        NameLabel.text = "\(self.connect.username)"
        MessageLabel.text = "\(self.connect.userPost)"
        
        
        }
        
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
