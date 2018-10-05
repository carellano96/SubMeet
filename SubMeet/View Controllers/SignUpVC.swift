//
//  SignUpVC.swift
//  gibber
//
//  Created by carlos arellano on 9/17/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SwiftKeychainWrapper
import CoreLocation

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var UserImage: UIImageView!
    @IBOutlet weak var UsernameField: UITextField!
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var RepPasswordField: UITextField!
    var userUID: String!
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var imageSelected = false
    var username: String!
    var imagePicker: UIImagePickerController!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancel(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    @IBAction func ChooseImage(_ sender: Any) {
              present(imagePicker, animated: true, completion: nil)
        
    }
    func keychain(){
        KeychainWrapper.standard.set(userUID, forKey: "uid")
    }
    
    @IBAction func SignUpButton(_ sender: Any) {
        if (UsernameField.text != "" && PasswordField.text != "" && PasswordField.text == RepPasswordField.text && imageSelected){
        Auth.auth().createUser(withEmail: EmailField.text!, password: PasswordField.text!, completion: { (user, error) in
            //no error in signing up!
            if error == nil{
                if let user = user {
                print("starting sign up!")
                print(user.uid,"uid name")
                self.userUID = user.uid
                self.username = self.UsernameField.text
                self.uploadImg(image: self.UserImage)
                    //img function
                self.UsernameField.text = ""
                self.PasswordField.text = ""
                self.RepPasswordField.text = ""
                self.EmailField.text = ""
                self.UserImage.image = UIImage(named: "pencil")

                self.keychain()

                self.performSegue(withIdentifier: "toFeedVC", sender: nil)  }
                
            }
            else{//error signing up!
                self.createAlert(title: "Error", message: (error?.localizedDescription)!)
            }
            })
        }
        else if (UsernameField.text != "" || PasswordField.text != ""){
            self.createAlert(title: "Error", message: "Username or password field not filled out!")
        }
        else if (PasswordField.text == RepPasswordField.text){
            self.createAlert(title: "Error", message: "Passwords do not match!")
        }
        else if (!imageSelected){
            self.createAlert(title: "Error", message: "Please upload an image!")
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    func createAlert(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            UserImage.image = image
            imageSelected = true
        }
        else{
            print("image not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
        
    }
    func setUpUser(img: String){
        let userData = [ "username": self.username, "userImg": img]
        print("added user tree to firebase")
        delegate.userImg = img
        delegate.username = username
        let setLocation = Database.database().reference().child("users").child(userUID)
        setLocation.setValue(userData)
        
    }
    func uploadImg(image: UIImageView){
        print("starting the upload img")
        guard let img = UserImage.image, imageSelected == true else{
            print("image not selected")
            return
        }
        
        username = UsernameField.text!
        if let data = UIImageJPEGRepresentation(img, 0.2){
        let imgUID = NSUUID().uuidString
        print(imgUID)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let storageRef = Storage.storage().reference()
        let storageItem = storageRef.child(imgUID)
            _ = storageItem.putData(data, metadata: metaData) {
            (metaData, error) in
            
            if error != nil {
                print((error?.localizedDescription)! + "didn't upload image!")
            
            }
            else{
                print("uploaded!")
                
               storageItem.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print("some error here?")
                        print(error?.localizedDescription)
                        return
                    }
                    if url != nil {
                        print("we did it!")
                        self.setUpUser(img: url!.absoluteString)
                    }
                    })
            }
        }
        
    }
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //Change password using current password, authenticate with credentials, then update password
    //change email, authenticate with current email, change email
    //change profile picture
    

}
