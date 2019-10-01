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
import CoreLocation

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var posts = [Post]()
    var post: Post!
    var imagePicker: UIImagePickerController!
    var userUID: String!
    var isRecent: Bool!
    let manager = CLLocationManager()
    var myLocation: CLLocationCoordinate2D!
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var isOn: Bool!
    var Handler: DatabaseHandle?
    var PostChosen: Post!
    var userChosen: String!
    var NoInternet: NoInternetConnection!

    private let refreshControl = UIRefreshControl()

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let updatedLocation = locations.first!
        if self.myLocation == nil {
            self.myLocation = updatedLocation.coordinate
            return
        }
        if self.myLocation.longitude != locations.first?.coordinate.longitude && self.myLocation.latitude != locations.first?.coordinate.latitude{
        let newCoordinate: CLLocationCoordinate2D = updatedLocation.coordinate
        let usrDefaults:UserDefaults = UserDefaults.standard
        print("getting longitudes & Lats")
        usrDefaults.set("\(newCoordinate.latitude)", forKey: "current_latitude")
        usrDefaults.set("\(newCoordinate.longitude)", forKey: "current_longitude")
        usrDefaults.synchronize()
        print("The username of this user is: \(delegate.username)")
        print("The userIMG of this user is:\(delegate.userImg)")
        let longitude = Double(UserDefaults.standard.string(forKey: "current_longitude")!)
        let latitude = Double(UserDefaults.standard.string(forKey: "current_latitude")!)
        if (longitude != nil && latitude != nil){
            myLocation = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)        }
            
        }
        print("my longitude is ", self.myLocation.longitude);
    }

    
    override func viewWillAppear(_ animated: Bool) {
        let testIsOn = UserDefaults.standard.string(forKey: "isOn")
        if testIsOn == nil {
            isOn = true
        }
        else{
            isOn = Bool(testIsOn!)
        }

    }
    
    

    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()

    }
    private func configureLocationManager(){
        
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = false
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }
    
    @IBAction func segmentedClicked(_ sender: Any){
        isRecent = !isRecent
        if (isRecent) {
            self.posts = self.posts.sorted(by: {$0.datePosted > $1.datePosted})
            self.tableView.reloadData()
        }
        else {
            self.posts = self.posts.sorted(by: { $0.likes > $1.likes})
            self.tableView.reloadData()
        }
        
    }
    

    
    //check to see if the user has connects, then for each connect check if user has new data
    
    func CheckforMessages(){
                    //store connect key to check if there are messages for key
                   let MessageRef = Database.database().reference().child("chats")
        MessageRef.observeSingleEvent(of: .value, with: {(snapshot) in
                        //if theres a child added
                    if let messages = snapshot.children.allObjects as? [DataSnapshot]{
                        //each convo
                        for conversation in messages{
                            if let convo = conversation.children.allObjects as? [DataSnapshot]{
                            
                            for message in convo {
                        if message.exists(){
                            if let messageData = message.value as? Dictionary<String, AnyObject>{
                                if (messageData["readByReciever"] as? Bool == false && messageData["senderID"] as? String != self.userUID)
                                {
                                    let messageVC1 = self.tabBarController?.tabBar.items?[2]
                                    if let tabbar = self.tabBarController?.tabBar.items?[2] as? UITabBarItem {
                                        tabbar.badgeValue = ""
                                    }}}}}}
                    }
        }
                    })
                }


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
        let postRef = Database.database().reference().child("posts")
        postRef.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                self.posts.removeAll()
                let radius = UserDefaults.standard.string(forKey: "sliderValue")
                let isOn = Bool(self.isOn)
                for data in snapshot {
                    if let postData = data.value as? Dictionary<String, AnyObject>{
                        let postKey = data.key
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

                        if !isOn && radius != nil {
                            postRef.child(postKey).child("location").observeSingleEvent(of: .value, with: {(snapshot) in
                                if let locationData = snapshot.value as? Dictionary<String, AnyObject>{
                                    let longitude = locationData["longitude"] as? Double
                                    let latitude = locationData["latitude"] as? Double
                                    let postLocation = CLLocation(latitude: latitude!, longitude: longitude!)//
                                    print(self.myLocation.latitude)
                                    let myLocation = CLLocation(latitude: self.myLocation.latitude, longitude: self.myLocation.longitude)
                                   let radiusFloat = Float(radius!)
                                    
                                    if self.compareRadius(radius: Int(radiusFloat!), userLocation: myLocation, postLocation: postLocation){
                                        //if its true then add it
                                        self.posts.append(post)
                                    }
                                }
                            
                            })
                            
                            
                            
                            
                        }
                        else{
                            self.posts.append(post)
                            print(post.userPost)
                        }
                    }
                }
            }
            if self.isRecent{
                self.posts = self.posts.sorted(by: {$0.datePosted > $1.datePosted})
            }
            else{
                self.posts = self.posts.sorted(by: { $0.likes > $1.likes})
            }
            
            self.tableView.reloadData()
        })
    }
    
    
    
    func compareRadius(radius: Int, userLocation: CLLocation, postLocation: CLLocation) -> Bool{
        let distance = userLocation.distance(from: postLocation)
        let distanceInMiles = Int(distance/1609.344)
        print("distance in Miles from this is", distanceInMiles)
        print("radius in Miles from this is", radius)

        if distanceInMiles > radius {
            return false
        }
        return true
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NoInternet = NoInternetConnection()
        tableView.delegate = self
        tableView.dataSource = self
        self.tabBarController?.delegate = self
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        isRecent = true
        self.configureLocationManager()
        self.manager.startUpdatingLocation()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        //self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.estimatedRowHeight = 132
        
        // Do any additional setup after loading the view.
        retrieveData()
        
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
        retrieveData()
    }
    

    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell{
                print("configuring cells")
                cell.configCell(post: post)
            cell.CommentButton.tag = indexPath.row
            cell.ProfileButton.tag = indexPath.row
            cell.MoreOptions.tag = indexPath.row
            cell.CommentButton.addTarget(self, action: #selector(GoToComments(sender:)), for: .touchUpInside)
            cell.ProfileButton.addTarget(self, action: #selector(GoToProfile(sender:)), for: .touchUpInside)
            cell.MoreOptions.addTarget(self, action: #selector(MoreOptions(sender:)), for: .touchUpInside)
                return cell
            }
        else{
        print("returning postcell")
        return PostCell()
        }

    }
    
    @objc func MoreOptions(sender: UIButton){
        let row = sender.tag
        let postKey = posts[row].postKey
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

    
    @objc func GoToProfile(sender: UIButton){
        let row = sender.tag
        userChosen = posts[row].userID
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc: UserVC = storyboard.instantiateViewController(withIdentifier: "UserVC") as? UserVC{
            vc.userID = userChosen
            vc.CancelButtonDisabled = false
            self.present(vc, animated: true, completion: nil)
            
        }
        
        
    }
    
    @objc func GoToComments(sender: UIButton){
        
        let row = sender.tag
        PostChosen = posts[row]
        self.performSegue(withIdentifier: "toComments", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments"{
            let vc = segue.destination as? CommentsVC
            if let _ = PostChosen{
                vc?.comments = PostChosen.comments
                vc?.postID = PostChosen.postKey
            }
            
        }
        else if segue.identifier == "toFilter"{
            let myLocation = CLLocation(latitude: self.myLocation.latitude, longitude: self.myLocation.longitude)
            let vc = segue.destination as? FilterTVC
            vc?.myLocation = myLocation
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableViewAutomaticDimension
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 700
    }

    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let tabBarIndex = tabBarController.selectedIndex
        
        print(tabBarIndex)
        
        if tabBarIndex == 1 {
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    

    
    @IBAction func returnToFeed(_ sender: UIStoryboardSegue){
        retrieveData()
        self.tableView.reloadData()
    }
    

}





//create an IBAction that sends the comments to the viewcontroller, prepareforsegue relevant comment information
