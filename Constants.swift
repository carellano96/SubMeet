//
//  Constants.swift
//  gibber
//
//  Created by carlos arellano on 9/13/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import Foundation
import Firebase
//Constants.refs.databaseChats
struct Constants {
    struct refs {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
    }
}
