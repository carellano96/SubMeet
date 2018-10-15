//
//  LoginViewController.swift
//  gibber
//
//  Created by carlos arellano on 9/13/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper

class LoginViewController: UIViewController, UITextFieldDelegate {
   
    @IBOutlet weak var UsernameField: UITextField!
    var SignIn: Bool = true
    var UserUID: String = ""
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var chosenTag: Int!

    @IBOutlet weak var PasswordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        UsernameField.delegate = self
        PasswordField.delegate = self
        UsernameField.tag = 0
        PasswordField.tag = 1
        UsernameField.returnKeyType = UIReturnKeyType.done
        PasswordField.returnKeyType = UIReturnKeyType.done
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        chosenTag = textField.tag
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("chosenTag", chosenTag)
            if chosenTag == 0 {
                if (self.view.frame.origin.y) == 0{
                    self.view.frame.origin.y -= ( UsernameField.frame.maxY - keyboardSize.height)
                    
                }
            }
            else{
                if (self.view.frame.origin.y) == 0{
                    self.view.frame.origin.y -= ( PasswordField.frame.maxY - keyboardSize.height)
                    
                }
            }
            
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
                
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: "uid"){
            performSegue(withIdentifier: "toFeed", sender: nil)
        }
    }
    
    func keychain(){
        
        KeychainWrapper.standard.set(UserUID, forKey: "uid")
    }
    
    @IBAction func signIn(_sender: AnyObject){
        if UsernameField.text == "" || PasswordField.text == "" {
            let alertController = UIAlertController(title: "Username Required", message: "Please enter a username or password!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        }
        else{
            Auth.auth().signIn(withEmail: UsernameField.text!, password: PasswordField.text!, completion: {
                (user, error) in
                if error == nil {
                    print("user signed in!")
                    self.UserUID = (user?.uid)!
                    print(self.UserUID,"userID signed in")
                    self.keychain()
                    
                    self.UsernameField.text = ""
                    self.PasswordField.text = ""
                    self.performSegue(withIdentifier: "toFeed", sender: nil)
                }
                else{
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        
            
    }
    
    @IBAction func SignOut(_ sender: UIStoryboardSegue){
        try! Auth.auth().signOut()
        KeychainWrapper.standard.removeObject(forKey: "uid")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUsername(){
        let currentUser = KeychainWrapper.standard.string(forKey: "uid")
        let usernameRef = Database.database().reference().child("users").child(currentUser!).observe(.value, with: {(snapshot) in
            if snapshot.exists(){
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                    for data in snapshot {
                        if data.key == "username" {
                        if let username = data.value as? String{
                            print("the snapshot has the username!")
                            self.delegate.username = username
                           // self.delegate.userImg = postData["userImg"] as! String
                            
                        }
                            
                        }
                        
                        if data.key == "userImg"{
                            if let userImg = data.value as? String{
                                self.delegate.userImg = userImg
                            }
                        }
                        
                        
                    }
                }
            }
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFeed"{
            getUsername()
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
