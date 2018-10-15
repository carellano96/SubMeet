//
//  CommentsVC.swift
//  SubMeet
//
//  Created by carlos arellano on 10/9/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class CommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var SendView: UIView!
    lazy var comments: [Comment]! = []
    var postID: String!
    var NoInternet: NoInternetConnection!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        self.textField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
        if self.comments.count > 0 {
            self.tableView.scrollToRow(at: NSIndexPath(row: self.comments.count-1, section: 0) as IndexPath, at: .bottom, animated: true)
            //self.tableView.selectRow(at: NSIndexPath(row: self.messages.count-1, section: 0) as IndexPath, animated: false, scrollPosition: .bottom)
        }
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("keyboard",self.SendView.frame.origin.y)
            let tabbar = self.view.frame.maxY - self.SendView.frame.maxY
            if (self.view.frame.origin.y) == 0{
                self.view.frame.origin.y -= (keyboardSize.size.height-tabbar)
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(at: NSIndexPath(row: self.comments.count-1, section: 0) as IndexPath, at: .bottom, animated: true)
                    //self.tableView.selectRow(at: NSIndexPath(row: self.messages.count-1, section: 0) as IndexPath, animated: false, scrollPosition: .bottom)
                }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("hide the keyboard!")
            if self.view.frame.origin.y != 0{
                print("hide the keyboard")
                self.view.frame.origin.y = 0
                
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("comment countr", comments.count)
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? CommentCell{
            cell.configCell(comment: comment)
            print(" comment", cell.CommentLabel.text!)
            return cell
        }
        else{
            return CommentCell()
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func PostComment(_ sender: AnyObject){
        if textField.text != ""{
        let commentText = textField.text
            var delegate = UIApplication.shared.delegate as! AppDelegate
            let username = delegate.username
            let userImg = delegate.userImg
            let userID = KeychainWrapper.standard.string(forKey: "uid")
        let CommentRef = Database.database().reference().child("posts").child(postID).child("comments").childByAutoId()
        let NewComment = ["commentText": commentText,
                          "userID": userID,
                          "userImg": userImg,
                          "username": username]
        CommentRef.setValue(NewComment)
        self.retrieveData()
        textField.text = ""
        //textField.resignFirstResponder()
        }
        else{
          createAlert(title: "Empty Comment", message: "You haven't written anything down!")
        }
        
    }
    
    
    func createAlert(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func retrieveData(){
        if !Reachability.Connection(){
            NoInternet.configView(width: self.view.frame.width, center: self.view.center, top: self.view.frame.maxY)
            self.view.addSubview(NoInternet)
            return
        }
        else{
            if self.view.subviews.contains(NoInternet){
                NoInternet.removeFromSuperview()
            }
        }
        let CommentRef = Database.database().reference().child("posts").child(postID).child("comments")
        CommentRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let comments = snapshot.children.allObjects as? [DataSnapshot]{
                self.comments.removeAll()
                for data in comments{
                    
                    if let commentData = data.value as? Dictionary<String, AnyObject>{
                    let commentKey = data.key
                    let NewComment = Comment(commentData: commentData, commentKey: commentKey)
                    self.comments.append(NewComment)
                        
                        
                    }
                    
                }
                
                
                
            }
            self.tableView.reloadData()
        })
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
