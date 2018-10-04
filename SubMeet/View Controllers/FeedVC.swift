//
//  FeedVC.swift
//  gibber
//
//  Created by carlos arellano on 9/17/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
var notification = 0;

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var posts = [Post]()
    var post: Post!
    var imagePicker: UIImagePickerController!
    var userUID: String!
    var isRecent: Bool!
    var delegate = UIApplication.shared.delegate as! AppDelegate
    private let refreshControl = UIRefreshControl()

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        print("The username of this user is: \(delegate.username)")
        print("The userIMG of this user is:\(delegate.userImg)")
        
        
    }
    
    @IBAction func segmentedClicked(_ sender: Any){
        isRecent = !isRecent
        print("isRecent", isRecent)
        if (isRecent) {
            self.posts = self.posts.sorted(by: {$0.datePosted > $1.datePosted})
            self.tableView.reloadData()
        }
        else {
            self.posts = self.posts.sorted(by: { $0.likes > $1.likes})
            print("now showing trending!")
            self.tableView.reloadData()
        }
        
    }
    

    
    //check to see if the user has connects, then for each connect check if user has new data
    
    func CheckforMessages(){
                    //store connect key to check if there are messages for key
                   let MessageRef = Database.database().reference().child("chats")
                MessageRef.observe(.value, with: {(snapshot) in
                        //if theres a child added
                    if let messages = snapshot.children.allObjects as? [DataSnapshot]{
                        //each convo
                        for conversation in messages{
                            print("specific message:",conversation)
                            if let convo = conversation.children.allObjects as? [DataSnapshot]{
                            
                            for message in convo {
                        if message.exists(){
                            if let messageData = message.value as? Dictionary<String, AnyObject>{
                                print("got the message!",messageData)
                                if (messageData["readByReciever"] as? Bool == false && messageData["senderID"] as? String != self.userUID)
                                {
                                    print("someone sent a message!")
                                    let messageVC1 = self.tabBarController?.tabBar.items?[2]
                                    print("This type is:",type(of: messageVC1))
                                    if let tabbar = self.tabBarController?.tabBar.items?[2] as? UITabBarItem {
                                        tabbar.badgeValue = ""
                                        print("changed the badge value!")
                                    }}}}}}
                    }
        }
                    })
                }

    override func viewDidLoad() {
        self.tableView.reloadData()
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tabBarController?.delegate = self
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        isRecent = true
        // Do any additional setup after loading the view.
        Database.database().reference().child("posts").observe(.value, with: {
            (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                self.posts.removeAll()
                for data in snapshot {
                    if let postData = data.value as? Dictionary<String, AnyObject>{
                        let postKey = data.key
                        print("data key is \(postKey)")
                        let post = Post(postKey: postKey, postData: postData)
                        self.posts.append(post)
                        print(self.posts.count," count!")
                    }
                }
            }
            if self.isRecent{
                self.posts = self.posts.sorted(by: {$0.datePosted > $1.datePosted})
            }
            else{
                self.posts = self.posts.sorted(by: { $0.likes > $1.likes})
            }
        })
        userUID = KeychainWrapper.standard.string(forKey: "uid")
        self.CheckforMessages()
        refreshControl.addTarget(self, action: #selector(fetchMessages(_sender:)), for: .valueChanged)
        let backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        let refreshColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        refreshControl.tintColor = refreshColor
        refreshControl.backgroundColor = backgroundColor
        if #available(iOS 10.0, *){
            tableView.refreshControl = refreshControl
        }
        else{
            tableView.addSubview(refreshControl)
        }
        
        
        // Do any additional setup after loading the view.
    }
    

    @objc private func fetchMessages(_sender: Any) {
        refreshMessages()
        refreshControl.endRefreshing()

    }
    private func refreshMessages(){
        self.tableView.reloadData()
        
    }
    

    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell{
                print("configuring cells")
                cell.configCell(post: post)
            self.checkforLikes(postKey: post.postKey)
                return cell
            }
        else{
        print("returning postcell")
        return PostCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let tabBarIndex = tabBarController.selectedIndex
        
        print(tabBarIndex)
        
        if tabBarIndex == 1 {
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func checkforLikes(postKey: String){
        
        Database.database().reference().child("posts").child(postKey).child("likes").observe(.value, with: {
            (snapshot) in
            
        })
        
    }
    
    
    
        
    
    
    
    

    


}
