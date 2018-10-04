//
//  PostCell.swift
//  SubMeet
//
//  Created by carlos arellano on 9/21/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class PostCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userPost: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var ConnectButton: UIButton!
    @IBOutlet weak var datePosted: UILabel!
    
    
    var post: Post!
    var postKey: DatabaseReference!
    let currentUser = KeychainWrapper.standard.string(forKey: "uid")
    var delegate = UIApplication.shared.delegate as! AppDelegate

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
    func configCell(post: Post, userImg: UIImage? = nil){
        
        self.post = post
        self.likesLabel.text = "\(post.likes)"
        self.username.text = "\(post.username)"
        self.userPost.text = "\(post.userPost)"
        //convert Date() to string and get time display rextension
        let dateInString = post.datePosted
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = dateFormatter.date(from: dateInString){
            let timeSincePost = date.timeAgoDisplay()
            print("time since post: ", timeSincePost)
            self.datePosted.text = timeSincePost
        }
        //
        if userImg != nil{
            self.userImg.image = userImg
        }else{
            //
            let ref = Storage.storage().reference(forURL: post.userImg)
            ref.getData(maxSize: 100000000, completion:{ (data,error) in
                
                print("are we here ")
                if (error != nil){
                    print("cell configuring")
                    print("couldn't get user img because !",error?.localizedDescription)
                }
                else{
                    
                    if let imgData = data {
                        
                        if let image = UIImage(data: imgData){
                            
                            self.userImg.image = image
                            print("cell configured!")
                        }
                    }
                }
                
            })
        }
        let likeRef: DatabaseReference? = Database.database().reference().child("users").child(currentUser!).child("likes").child(post.postKey)
        let userID = KeychainWrapper.standard.string(forKey: "uid")
        if userID == post.userID {
            if let _ = ConnectButton{
            ConnectButton.isHidden = true
            }
        }

    }
    

    
    @IBAction func Liked(_ sender: AnyObject){
        
        let likeRef = Database.database().reference().child("users").child(currentUser!).child("likes").child(post.postKey)
        likeRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                self.post.AddLikes(AddLike: true)
                likeRef.setValue(true)
            }
            else{
                self.post.AddLikes(AddLike: false)
                likeRef.removeValue()
            }
        })
        
    }
    
    @IBAction func Connected(_ sender: AnyObject){
        
        let ConnectRef = Database.database().reference().child("users").child(currentUser!).child("connects").childByAutoId()
        let ConnectedID = ConnectRef.key
        
        ConnectRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let _ = snapshot.value as? NSNull{
                print(self.post.username, ": Post was posted by this person")
                ConnectRef.child("userID").setValue(self.post.userID)
                ConnectRef.child("username").setValue(self.post.username)
                ConnectRef.child("userImg").setValue(self.post.userImg)
                ConnectRef.child("userPost").setValue(self.post.userPost)
                ConnectRef.child("postID").setValue(self.post.postKey)
            }
            else{
                ConnectRef.removeValue()
            }
        })
        
        let UserConnectRef = Database.database().reference().child("users").child(post.userID).child("connects").child(ConnectedID)
        
        UserConnectRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let _ = snapshot.value as? NSNull{
                print(self.delegate.username, ": Post was posted myself")
                let uid = KeychainWrapper.standard.string(forKey: "uid")
                UserConnectRef.child("userID").setValue(uid)
                UserConnectRef.child("username").setValue(self.delegate.username)
                UserConnectRef.child("userImg").setValue(self.delegate.userImg)
                UserConnectRef.child("userPost").setValue(self.post.userPost)
                ConnectRef.child("postID").setValue(self.post.postKey)

            }
            else{
                UserConnectRef.removeValue()
            }
        })
    }
    


}


extension Date{
    func timeAgoDisplay() -> String {
    
    let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        if secondsAgo < minute {
            return "\(secondsAgo) seconds ago"
        }
        else if secondsAgo < hour {
            return "\(secondsAgo/minute) minutes ago"

        }
        else if secondsAgo < day {
            return "\(secondsAgo/hour) hours ago"

        }
        else if secondsAgo < week{
        return "\(secondsAgo/day) days ago"
        }
        
        return "\(secondsAgo/week) weeks ago"
        
        
    }
}
