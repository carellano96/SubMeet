//
//  Posts.swift
//  SubMeet
//
//  Created by carlos arellano on 9/21/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

class Post{
    
    private var _username: String!
    private var _userImg: String!
    private var _userPost: String!
    private var _likes: Int!
    private var _PostKey: String!
    private var _postRef: DatabaseReference!
    private var _userID: String!
    private var _datePosted: String!
    private var _date: Date!
    
    
    var datePosted: String{
        return _datePosted
    }
    var date: Date{
        get{
        return _date
        }
        set{
            _date = newValue
        }
    }
    var username: String{
        return _username
    }
    var userImg: String {
        return _userImg
    }
    
    var userPost: String {
        get{
        return _userPost
        }
        set{
            _userPost = newValue
        }
    }
    
    var likes: Int{
        return _likes;
    }
    
    var postKey: String{
        return _PostKey
    }
    
    var userID: String{
        get{
            return _userID
        }
        set{
            _userID = newValue
        }
    }
    
    
    
    init(likes: Int, userPost: String, userImg: String, userID: String){
        _likes = likes
        _userPost = userPost
        _userImg = userImg
        _userID = userID
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>){
        _PostKey = postKey
        
        if let username = postData["username"] as? String {
            _username = username
        }
        
        if let userPost = postData["userPost"] as? String{
            _userPost = userPost
        }
        
        if let userImg = postData["userImg"] as? String{
            _userImg = userImg
        }
        
        if let likes = postData["likes"] as? Int{
            _likes = likes
        }
        if let userID = postData["userID"] as? String{
            _userID = userID
        }
        if let datePosted = postData["datePosted"] as? String{
            _datePosted = datePosted
        }
        
        let dateFormatter = DateFormatter()
        if let datePosted = datePosted as? String {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
            date = dateFormatter.date(from: datePosted)!
        }
        _postRef = Database.database().reference().child("posts").child(_PostKey)
        
        
    }
    
    func AddLikes(AddLike: Bool){
        if AddLike {
            _likes = _likes + 1
        }
        else{
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
        
        
        
    }
    

    
    
}
