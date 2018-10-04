//
//  MessageCell.swift
//  SubMeet
//
//  Created by carlos arellano on 9/29/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var SenderMessage: MessageView!
    @IBOutlet weak var RecipientMessage: MessageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func configCell(message: Message){
        if message.isSelf {
            RecipientMessage.isHidden = true
            SenderMessage.isHidden = false
            SenderMessage.MessageText.text = message.text
        }
        else{
            SenderMessage.isHidden = true
            RecipientMessage.isHidden = false
            RecipientMessage.MessageText.text = message.text
        }
        //SenderMessage.sizeToFit()
        //RecipientMessage.sizeToFit()

    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
