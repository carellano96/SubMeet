//
//  ComposeVC.swift
//  SubMeet
//
//  Created by carlos arellano on 9/24/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ComposeVC: UIViewController, UITextViewDelegate {
    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet weak var ComposeTextField: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ComposeTextField.delegate = self
        ComposeTextField.returnKeyType = UIReturnKeyType.done
    }

    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func Cancel(_ sender: AnyObject){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Submit(_ sender: AnyObject){
        let idea = ComposeTextField.text
        let userID = Auth.auth().currentUser?.uid
        print(userID!)
        Database.database().reference().child("users").child(userID!).observeSingleEvent(of: .value, with: {(snapshot) in
            if let data = snapshot.value as? Dictionary<String, AnyObject>{
            print(data)
            print("we got the data!")
            let username = data["username"]
            let userImg = data["userImg"]
            let userID = KeychainWrapper.standard.string(forKey: "uid")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"

            let date = Date()
                print("current date", date.description)
            let dateString: String = dateFormatter.string(from: date)
            print("dateposted",dateString)
            let post: Dictionary<String, AnyObject> = [
                "username": username!,
                "userImg": userImg!,
                "userPost": idea as AnyObject,
                "likes": 0 as AnyObject,
                "userID": userID as AnyObject,
                "datePosted": dateString as AnyObject
            ]
            
            let firebasePost = Database.database().reference().child("posts").childByAutoId()
            firebasePost.setValue(post)
            }
            
        })
        
        navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ComposeTextField.becomeFirstResponder()
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
