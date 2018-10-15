//
//  Connect.swift
//  SubMeet
//
//  Created by carlos arellano on 9/29/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import Foundation
import Firebase

class Connect{
    
    private var _username: String!
    private var _userID: String!
    private var _userImg: String!
    private var _userPost: String!
    private var _postID: String!
    private var _connectKey: String!
    private var _connectNotification: String!
    
    var connectNotification: String{
        get{
            return _connectNotification
        }
        set{
            _connectNotification = newValue
        }
    }
    var connectKey: String{
        get{
            return _connectKey
        }
        set{
            _connectKey = newValue
        }
    }
    var username: String{
        return _username
    }
    
    var userID: String {
        return _userID
    }
    
    
    var userImg: String{
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
    var postID: String{
        return _postID
    }
    
    init(username: String, userID: String, userImg: String){
        _username = username
        _userID = userID
        _userImg = userImg
    }
    
    init(connectData: Dictionary<String, AnyObject>, connectKey: String!){
        _username = connectData["username"] as? String
        _userImg = connectData["userImg"] as? String
        _userPost = connectData["userPost"] as? String
        _userID = connectData["userID"] as? String
        _postID = connectData["postID"] as? String
        _connectKey = connectKey
        _connectNotification = "0"
    }
    
    
    
}
