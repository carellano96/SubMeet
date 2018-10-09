//
//  File.swift
//  SubMeet
//
//  Created by carlos arellano on 10/9/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import Foundation

class Comment{
    private var _comment: String!
    private var _userID: String!
    private var _userImg: String!
    private var _commentKey: String!
    private var _username: String!
    
    var username: String{
        return _username
    }
    var commentKey: String{
        return _commentKey
    }
    var comment: String{
        get{
            return _comment
        }
        set{
            _comment = newValue
        }
    }
    var userID: String{
        get{
            return _userID
        }
        set{
            _userID = newValue
        }
    }
    var userImg: String{
        get{
            return _userImg
        }
        set{
            _userImg = newValue
        }
    }
    
    init(comment: String, userID: String, userImg: String, commentKey: String, username: String){
        _username = username
        _comment = comment
        _userID = userID
        _userImg = userImg
        _commentKey = commentKey
    }
    
    init(commentData: Dictionary<String, AnyObject>, commentKey: String){
        _commentKey = commentKey
        _comment = commentData["commentText"] as? String
        _userID = commentData["userID"] as? String
        _userImg = commentData["userImg"] as? String
        _username = commentData["username"] as? String
    }
    
}
