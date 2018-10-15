//
//  ConnectVC.swift
//  SubMeet
//
//  Created by carlos arellano on 9/29/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ConnectVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var connects = [Connect]()
    var connect: Connect!
    var connectKey: String!
    var ChosenUser: String!
    var ChosenUserID: String!
    var currentUser: String!
    var alreadyReloaded: Bool!
    var previousNotificationNumber = 0
    var NoInternet: NoInternetConnection!
    private let refreshControl = UIRefreshControl()
    var highestMessageNum = 0
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alreadyReloaded = false
        alreadyReloaded = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        NoInternet = NoInternetConnection()
        currentUser = KeychainWrapper.standard.string(forKey: "uid")
        let connectsRef = Database.database().reference().child("users").child(currentUser!).child("connects")
        
        connectsRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.connects.removeAll()
                print("removing all the connects and adding them again!")
                for data in snapshot {
                    if let connectData = data.value as? Dictionary<String, AnyObject>{
                        let connectKey = data.key //post key essentially
                        let connect = Connect(connectData: connectData, connectKey: connectKey)
                        self.connects.append(connect)
                    }
                    
                    
                    
                }
            }

            self.tableView.reloadData()

        })
        print("print connect counter,",connects.count)

        
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
    }
    private func refreshMessages(){
        self.tableView.reloadData()
        checkForInternet(){(success) -> Void in
            if success{
                refreshControl.endRefreshing()
            }
            
        }

    }
    
    
    func checkForInternet( completion: (_ success: Bool) -> Void){
        if !Reachability.Connection(){
            NoInternet.configView(width: self.view.frame.width - 10, center: self.view.center, top: self.view.frame.minY - 40)
            
            
            self.view.addSubview(NoInternet)
            
        }
        else{
            if self.view.subviews.contains(NoInternet){
                NoInternet.removeView()
            }
        }
        completion(true)
        
    }
    
    func CheckforMessages(cell: ConnectCell){
        //store connect key to check if there are messages for key
        let MessageRef = Database.database().reference().child("chats")
        MessageRef.observe(.value, with: {(snapshot) in
            //if theres a child added
            //chat
            print("im here connect")
                print("looking through connects!")
            var totalMessages = 0
            
            if let conversation = snapshot.childSnapshot(forPath: (cell.connect.connectKey)).children.allObjects as? [DataSnapshot] {
                //each convo
                        print("found the connect")
                        for message in conversation {
                            if message.exists(){
                                print("looking though connect message!")
                                if let messageData = message.value as? Dictionary<String, AnyObject>{
                                    if (((messageData["readByReciever"] as? Bool)! == false) && (messageData["senderID"] as? String != self.currentUser))
                                    {
                                        print("found the unread message!")
                                        totalMessages = totalMessages + 1
                                        
                                        }}}
                            
                }
                    cell.connect.connectNotification = "\(totalMessages)"
                if self.previousNotificationNumber != Int(cell.connect.connectNotification){
                    print("previous number is not equal and its updating!")
                    self.previousNotificationNumber = Int(cell.connect.connectNotification)!
                    self.alreadyReloaded = false
                }
                    print("connect notification in firebase is", cell.connect.connectNotification)

                if Int(cell.connect.connectNotification)! > 0{
                    cell.Notification.isHidden = false
                    cell.Notification.NotificationNumber.text = "\(cell.connect.connectNotification)"
                    cell.MessageLabel.font = UIFont.boldSystemFont(ofSize: 17)
                }
                else{
                    cell.Notification.isHidden = true
                    cell.MessageLabel.font = UIFont.systemFont(ofSize: 17)
                }
            }
            
            //alreadyreloaded is false which loads cells, firebase checks data, update the notification view, make already reloaded true and table reloads
            if self.alreadyReloaded == false {
                self.tableView.reloadData()
                self.alreadyReloaded = true
            }
        
        })
        
        
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connects.count
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let connect = self.connects[indexPath.row]
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "ConnectCell") as? ConnectCell
        {
            cell.configCell(connect: connect)
            print("connect notification is:", connect.connectNotification)
            Database.database().reference().child("users").child(connect.userID).child("userImg").observeSingleEvent(of: .value, with: {(snapshot) in
                if snapshot.exists(){
                    if let imgURL = snapshot.value as? String {
                        let connectImgRef = Storage.storage().reference(forURL: imgURL)
                        connectImgRef.getData(maxSize: 100000000, completion: {(data, error) in
                            if error != nil {
                                print("couldn't retrieve image!", error?.localizedDescription)
                            }
                            else {
                                if let imgData = data {
                                    let image = UIImage(data: imgData)
                                    cell.ConnectImage.image = image
                                }
                            }
                        })
                        
                    }
                    
                    
                }
            })
            self.CheckforMessages(cell: cell)
            return cell
        }
        else{
            return ConnectCell()
        }
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ConnectCell{
            cell.connect.connectNotification = "0"
            connectKey = cell.connect.connectKey
            ChosenUser = cell.connect.username
            ChosenUserID = cell.connect.userID
            performSegue(withIdentifier: "toMessages", sender: nil)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let MessagesVC = segue.destination as? MessageVC{
            MessagesVC.connectKey = self.connectKey
            MessagesVC.title = ChosenUser
            MessagesVC.userChosenID = ChosenUserID
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            connectKey = connects[indexPath.row].connectKey
            let ConversationRef = Database.database().reference().child("chats").child(connectKey)
            ConversationRef.removeValue()
            let userUID = KeychainWrapper.standard.string(forKey: "uid")
            let ConnectRef = Database.database().reference().child("users").child(userUID!).child("connects").child(connectKey)
            
            ConnectRef.removeValue()
            let connectUID = connects[indexPath.row].userID
            let UsersConnectRef = Database.database().reference().child("users").child(connectUID).child("connects").child(connectKey)
            UsersConnectRef.removeValue()
            self.tableView.reloadData()
            
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
    
    
    //To Do
    //create a delete convo option
    //create a settings option to change username and userImg and password?

}
