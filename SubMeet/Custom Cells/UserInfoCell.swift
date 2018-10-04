//
//  UserInfoCell.swift
//  SubMeet
//
//  Created by carlos arellano on 9/29/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class UserInfoCell: UITableViewCell {
    @IBOutlet weak var UserProfile: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var totalLikes: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func configureCell(username: String!, userImg: String!){
        self.username.text = username
        let ref = Storage.storage().reference(forURL: userImg)
        ref.getData(maxSize: 10000000, completion: {(data, error) in
            if error != nil{
                print("couldn't retrieve user Img!")
            }
            else{
                
                if let imgData = data {
                    let image = UIImage(data: imgData)
                    self.UserProfile.image = image
                }
            }
        })

    }

}
