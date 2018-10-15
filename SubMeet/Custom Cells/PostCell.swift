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
    @IBOutlet weak var userImg: UserProfile!
    @IBOutlet weak var userPost: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var ConnectButton: UIButton!
    @IBOutlet weak var datePosted: UILabel!
    @IBOutlet weak var CommentsLabel: UILabel!
    @IBOutlet weak var CommentButton: UIButton!
    @IBOutlet weak var LikeButton: UIButton!
    @IBOutlet weak var ProfileButton: UIButton!
    @IBOutlet weak var MoreOptions: UIButton!
    @IBOutlet weak var PostView: UIView!
    
    
    var post: Post!
    var postKey: DatabaseReference!
    let currentUser = KeychainWrapper.standard.string(forKey: "uid")
    var delegate = UIApplication.shared.delegate as! AppDelegate

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        PostView.layer.shadowColor = UIColor.lightGray.cgColor
        PostView.layer.shadowOpacity = 1
        PostView.layer.shadowOffset = CGSize.zero
        PostView.layer.shadowRadius = 2
        userPost.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    func getUserImageURL(userUID: String) {
        var url = ""
        
        let imageRef = Database.database().reference().child("users").child(userUID)
        imageRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let data = snapshot.value as? Dictionary< String, AnyObject>{
                url = (data["userImg"] as? String)!
                self.userImg.imageURL = url
                if let imageFromCache = self.imageCache.object(forKey: url as AnyObject){
                    self.userImg.image = imageFromCache as? UIImage
                    self.userImg.userID = userUID
                    print("its in the cache!")
                    return
                }

                let ref = Storage.storage().reference(forURL: url)
                ref.getData(maxSize: 100000000, completion:{ (data,error) in
                    
                    print("are we here ")
                    if (error != nil){
                        print("couldn't get user img because !",error?.localizedDescription)
                    }
                    else{
                        
                        if let imgData = data {
                            
                            if let image = UIImage(data: imgData){
                                let CachedImage = image
                                if self.userImg.imageURL == url{
                                self.userImg.image = CachedImage
                                self.userImg.userID = userUID
                                }
                                self.imageCache.setObject(CachedImage, forKey: url as AnyObject)

                            }
                        }
                    }
                    
                })
            }
            
            
        })
        
        

        
    }
    
    
    func configCell(post: Post, userImg: UIImage? = nil){
        
        self.post = post
        self.likesLabel.text = "\(post.likes)"
        self.username.text = "\(post.username)"
        self.userPost.text = "\(post.userPost)"
        self.CommentsLabel.text = "\(self.post.comments.count)"
        print(post.userPost)
        //convert Date() to string and get time display rextension
        let dateInString = post.datePosted
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = dateFormatter.date(from: dateInString){
            let timeSincePost = date.timeAgoDisplay()
            self.datePosted.text = timeSincePost
        }
        //
        if userImg != nil{
            self.userImg.image = userImg
        }else{
            //
        
            //getuserImageURL
            getUserImageURL(userUID: post.userID)
            
            
        }
        let likeRef: DatabaseReference? = Database.database().reference().child("users").child(currentUser!).child("likes").child(post.postKey)
        let userID = KeychainWrapper.standard.string(forKey: "uid")
        if userID == post.userID {
            if let _ = ConnectButton{
            ConnectButton.isHidden = true
            }
            if let _ = MoreOptions{
                MoreOptions.isHidden = false
                print("more options is not hidden!")
            }
        }
        
        else{
            if let _ = ConnectButton{
                ConnectButton.isHidden = false
            }
            if let _ = MoreOptions{
            MoreOptions.isHidden = true
                print("more options is hidden!")

            }
        }
    }


    
    @IBAction func Liked(_ sender: AnyObject){
        
        let likeRef = Database.database().reference().child("users").child(currentUser!).child("likes").child(post.postKey)
        likeRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                self.post.AddLikes(AddLike: true)
                likeRef.setValue(true)
                var likes = Int(self.likesLabel.text!)!
                likes += 1
                self.likesLabel.text = "\(likes)"
                
            }
            else{
                self.post.AddLikes(AddLike: false)
                likeRef.removeValue()
                var likes = Int(self.likesLabel.text!)!
                likes -= 1
                self.likesLabel.text = "\(likes)"
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
