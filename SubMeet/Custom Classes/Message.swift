//
//  Message.swift
//  SubMeet
//
//  Created by carlos arellano on 9/29/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import Foundation

class Message{
    private var _senderID: String!
    private var _text: String!
    private var _messageID: String!
    private var _isSelf: Bool!
    
    var isSelf: Bool{
        get{
            return _isSelf
        }
        set{
            _isSelf = newValue
        }
    }
    
    var senderID: String {
        return _senderID
    }
    
    var text: String{
        return _text
    }
    
    init(name: String, senderID: String, text: String, messageID: String){
        _senderID = senderID
        _text = text
        _messageID = messageID
    }
    
    init(messageData: Dictionary<String, AnyObject>, messageKey: String){
        if let senderID = messageData["senderID"] as? String{
            _senderID = senderID
        }
        if let text = messageData["text"] as? String{
            _text = text
        }
        _messageID = messageKey
    }
}
