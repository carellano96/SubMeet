//
//  UserVC.swift
//  SubMeet
//
//  Created by carlos arellano on 9/26/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//
//dont forget to set up the TOTAL LIKES COUNTEr

import UIKit
import FirebaseStorage
import Firebase
import SwiftKeychainWrapper

class UserVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var MyPosts = [Post]()
    var isSelfProfile: Bool = true;
    var delegate = UIApplication.shared.delegate as! AppDelegate
    let UserMenu = ["My Posts","My Connects"]
    var userImg: String = ""
    var username: String = ""
    var CancelButtonDisabled = true
    var PostChosen: Post!
    var NoInternet: NoInternetConnection!
    var userID: String? = KeychainWrapper.standard.string(forKey: "uid")
    private let refreshControl = UIRefreshControl()

    func retrieveData(){
        if !Reachability.Connection(){
            NoInternet.configView(width: self.view.frame.width - 10, center: self.view.center, top: self.view.frame.minY - 40)
            
            
            self.view.addSubview(NoInternet)
            
            return
        }
        else{
            if self.view.subviews.contains(NoInternet){
                NoInternet.removeView()
            }
        }
        Database.database().reference().child("posts").observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                self.MyPosts.removeAll()
                for data in snapshot {
                    if let postData = data.value as? Dictionary<String, AnyObject>{
                        print(data)
                        if let userID = postData["userID"] as? String  {
                            if userID == self.userID {
                                let postKey = data.key
                                print("data key is \(postKey)")
                                let post = Post(postKey: postKey, postData: postData)
                                if let commentData = postData["comments"] as? Dictionary<String, AnyObject>{
                                    for comment in commentData{
                                        //create the comment
                                        let commentKey = comment.key
                                        if let commentDict = comment.value as? Dictionary<String, AnyObject>{
                                            let CurrentComment = Comment(commentData: commentDict, commentKey: commentKey)
                                            post.comments.append(CurrentComment)
                                            print(CurrentComment.comment)
                                            
                                        }
                                        
                                    }
                                }
                                self.MyPosts.append(post)
                            }
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        userImg = delegate.userImg
        username  = delegate.username
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
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
        NoInternet = NoInternetConnection()
        retrieveData()
        

        
        // Do any additional setup after loading the view.
    }
    
    @objc private func fetchMessages(_sender: Any) {
        refreshMessages()
        refreshControl.endRefreshing()
        
    }
    private func refreshMessages(){
        retrieveData()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0{
            return 1
        }
        else{
        return MyPosts.count
        }
    }
    @objc func CancelButton(sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell") as? UserInfoCell{
            print("configuring usercell")
            if let _ = userID{
            cell.configureCell(userID: userID)
            var totalLikes = 0;
            for post in MyPosts{
                totalLikes += post.likes
            }
            cell.totalLikes.text = "\(totalLikes)"
            if let button = cell.CancelButton{
                
            button.addTarget(self, action: #selector(CancelButton(sender:)), for: .touchUpInside)
                if CancelButtonDisabled{
                    button.isHidden = true
                    button.isEnabled = false
                }
                else{
                    button.isHidden = false
                    button.isEnabled = true
                }
            }
            
            return cell
            }
            }
        }
        else if let _ = userID {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell{
            let post = self.MyPosts[indexPath.row]
            print("configuring cells")
            cell.CommentButton.tag = indexPath.row
            cell.MoreOptions.tag = indexPath.row
            cell.configCell(post: post)
            cell.CommentButton.addTarget(self, action: #selector(GoToComments(sender:)), for: .touchUpInside)
            cell.MoreOptions.addTarget(self, action: #selector(MoreOptions(sender:)), for: .touchUpInside)
            return cell
        }


        }
        return PostCell()
    }
    

    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1
        {
        return 700
        }
        return 300
    }
    @objc func MoreOptions(sender: UIButton){
        let row = sender.tag
        let postKey = MyPosts[row].postKey
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
            self.DeleteAPost(postKey: postKey)
            self.retrieveData()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    func DeleteAPost(postKey: String){
        let postRef = Database.database().reference().child("posts").child(postKey)
        postRef.removeValue()
        
    }
    
    @objc func GoToComments(sender: UIButton){
        
        let row = sender.tag
        PostChosen = MyPosts[row]
        self.performSegue(withIdentifier: "toComments", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments"{
            let vc = segue.destination as? CommentsVC
            if let _ = PostChosen{
                print("post has been chosen!")
                vc?.comments = PostChosen.comments
                vc?.postID = PostChosen.postKey
            }
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
           return UITableViewAutomaticDimension

        }
        else{
            return 207
        }
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
