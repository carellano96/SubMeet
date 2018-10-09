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
        
        usrDefaults.set("\(newCoordinate.latitude)", forKey: "current_latitude")
        usrDefaults.set("\(newCoordinate.longitude)", forKey: "current_longitude")
        usrDefaults.synchronize()
        print("The username of this user is: \(delegate.username)")
        print("The userIMG of this user is:\(delegate.userImg)")
        let longitude = Double(UserDefaults.standard.string(forKey: "current_longitude")!)
        let latitude = Double(UserDefaults.standard.string(forKey: "current_latitude")!)
        if (longitude != nil && latitude != nil){
            myLocation = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            print("My location is: ,", myLocation.latitude)
        }
        }
        

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
        print("i appeared!")
        retrieveData()
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
        MessageRef.observeSingleEvent(of: .value, with: {(snapshot) in
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


    func retrieveData(){
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
                        print("data key is \(postKey)")
                        let post = Post(postKey: postKey, postData: postData)
                        if let commentData = postData["comments"] as? Dictionary<String, AnyObject>{
                            for comment in commentData{
                                //create the comment
                                let commentKey = comment.key
                                if let commentDict = comment.value as? Dictionary<String, AnyObject>{
                                    let CurrentComment = Comment(commentData: commentDict, commentKey: commentKey)
                                    post.comments.append(CurrentComment)
                                        print("Congrats!")
                                        print(CurrentComment.comment)
                                    
                                }
                                
                            }
                        }

                        print("isOn: \(isOn) and radius = \(radius)")
                        if !isOn && radius != nil {
                            print("will compare radius")
                            postRef.child(postKey).child("location").observeSingleEvent(of: .value, with: {(snapshot) in
                                if let locationData = snapshot.value as? Dictionary<String, AnyObject>{
                                    let longitude = locationData["longitude"] as? Double
                                    let latitude = locationData["latitude"] as? Double
                                    print("longitude is ", longitude)
                                    print("latitude is ", latitude)
                                    let postLocation = CLLocation(latitude: latitude!, longitude: longitude!)//
                                    print(self.myLocation.latitude)
                                    let myLocation = CLLocation(latitude: self.myLocation.latitude, longitude: self.myLocation.longitude)
                                   let radiusFloat = Float(radius!)
                                    print("radiusFloat,", radiusFloat)
                                    
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
    }
    
    
    
    func compareRadius(radius: Int, userLocation: CLLocation, postLocation: CLLocation) -> Bool{
        print("here?")
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
        self.tableView.reloadData()
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tabBarController?.delegate = self
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        isRecent = true
        self.configureLocationManager()
        self.manager.startUpdatingLocation()

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
    
    @IBAction func returnToFeed(_ sender: UIStoryboardSegue){
        retrieveData()
        self.tableView.reloadData()
    }
    
    
    
        
    
    
    
    

    


}

//create an IBAction that sends the comments to the viewcontroller, prepareforsegue relevant comment information
