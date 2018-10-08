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

class UserVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var MyPosts = [Post]()
    var isSelfProfile: Bool = true;
    var delegate = UIApplication.shared.delegate as! AppDelegate
    let UserMenu = ["My Posts","My Connects"]
    var userImg: String = ""
    var username: String = ""
    private let refreshControl = UIRefreshControl()

    func retrieveData(){
        Database.database().reference().child("posts").observe(.value, with: {
            (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                self.MyPosts.removeAll()
                for data in snapshot {
                    if let postData = data.value as? Dictionary<String, AnyObject>{
                        print(data)
                        if let username = postData["username"]  {
                            let username = username as? String
                            if username == self.delegate.username {
                                let postKey = data.key
                                print("data key is \(postKey)")
                                let post = Post(postKey: postKey, postData: postData)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell") as? UserInfoCell{
            print("configuring usercell")
            cell.configureCell(username: delegate.username, userImg: delegate.userImg)
            return cell
            }
        }
        else{
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell{
            let post = self.MyPosts[indexPath.row]
            print("configuring cells")
            cell.configCell(post: post)
            return cell
        }


        }
        return PostCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
        return 132
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
