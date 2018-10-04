//
//  MessageVC.swift
//  SubMeet
//
//  Created by carlos arellano on 9/29/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper



class MessageVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var SendView: UIView!
    var isVisible = true;
    var connectKey = ""
    var cell: MessageCell!
    var firstCall = true
    var userUID = KeychainWrapper.standard.string(forKey: "uid")
    var messages: [Message!] = []
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.tabBarItem.badgeValue = nil
        isVisible = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        isVisible = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        textField.returnKeyType = UIReturnKeyType.done
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.estimatedRowHeight = 300        //first observe if theres any messages there
        let MessageRef = Database.database().reference().child("chats").child(connectKey)
        MessageRef.observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                self.messages.removeAll()
                for data in snapshot{
                    if let messageData = data.value as? Dictionary<String, AnyObject>{
                    
                        let messageID = data.key
                        let message = Message(messageData: messageData, messageKey: messageID)
                        if let messageSenderID = messageData["senderID"] as? String{
                            if messageSenderID == self.userUID{
                                message.isSelf = true
                            }
                            else{
                                message.isSelf = false
                                if (self.isVisible){
                                MessageRef.child(messageID).child("readByReciever").setValue(true)
                                }
                                }
                        }
                        self.messages.append(message)
                    }
                    
                }
                
                
                //configure cell
                
            }
            print("reloading!")
            self.tableView.reloadData()
            if self.messages.count > 0 {
            self.tableView.scrollToRow(at: NSIndexPath(row: self.messages.count-1, section: 0) as IndexPath, at: .bottom, animated: false)
            //self.tableView.selectRow(at: NSIndexPath(row: self.messages.count-1, section: 0) as IndexPath, animated: false, scrollPosition: .bottom)
            }
        })
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
        if self.messages.count > 0 {
            self.tableView.scrollToRow(at: NSIndexPath(row: self.messages.count-1, section: 0) as IndexPath, at: .bottom, animated: true)
            //self.tableView.selectRow(at: NSIndexPath(row: self.messages.count-1, section: 0) as IndexPath, animated: false, scrollPosition: .bottom)
        }
    }
    var desiredHeight: CGFloat!
    var KeyBoardChangedHeight: CGFloat!

    func textFieldDidBeginEditing(_ textField: UITextField) {
            print("now editing on keyboard!")
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("keyboard",self.SendView.frame.origin.y)
            let tabbar = self.view.frame.height - self.SendView.frame.origin.y
            print("tabbar keyboard", tabbar)
            print("tabbar desired height,",(self.view.frame.origin.y + tabbar))
            if (self.view.frame.origin.y) == 0{
                self.view.translatesAutoresizingMaskIntoConstraints = true
                self.view.frame.origin.y -= (keyboardSize.height-55)
                if self.messages.count > 0 {
                    self.tableView.scrollToRow(at: NSIndexPath(row: self.messages.count-1, section: 0) as IndexPath, at: .bottom, animated: true)
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
                self.view.translatesAutoresizingMaskIntoConstraints = false

            }
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("resigning first responder")
        return true
    }
    

    
    @IBAction func SendMessage(_ sender: Any){
        if textField.text != ""{
        let MessageSent = textField.text
        let MessageRef = Database.database().reference().child("chats").child(connectKey).childByAutoId()
            let messageData = ["senderID": self.userUID, "text":MessageSent, "readByReciever": false] as [String : Any]
            MessageRef.setValue(messageData)
        }
        textField.text = ""

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell{
            cell.configCell(message: message!)
            return cell
        }
        else{
            return MessageCell()
        }
    }
    
    
    
    

    
    


    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
