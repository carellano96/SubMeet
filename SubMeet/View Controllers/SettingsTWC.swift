//
//  SettingsTWC.swift
//  SubMeet
//
//  Created by carlos arellano on 10/8/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
class SettingsTWC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var profileImage: UIImageView!
    let delegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func ChangeProfile(_ sender: AnyObject){
        present(imagePicker, animated: true, completion: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        let imageURL = delegate.userImg
        getUserProfile(userImg: imageURL)
        
    }
    
    func getUserProfile(userImg: String!){
        let ref = Storage.storage().reference(forURL: userImg)
        ref.getData(maxSize: 10000000, completion: {(data, error) in
            if error != nil{
                print("couldn't retrieve user Img!")
            }
            else{
                
                if let imgData = data {
                    let image = UIImage(data: imgData)
                    self.profileImage.image = image
                }
            }
        })
        
    }
    
    @IBAction func ReturnFromChange(_ sender: UIStoryboardSegue){

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
         profileImage.image = image
        uploadImage(image: profileImage)
            
            
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(image: UIImageView){
        guard let profile = image.image else {
            return
        }
        let userUID = KeychainWrapper.standard.string(forKey: "uid")
        let imageRef = Database.database().reference().child("users").child(userUID!)
        imageRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let data = snapshot.value as? Dictionary<String, AnyObject> {
                let imgUID = data["imgUID"] as? String
                print("got the imgUID", imgUID!)
                if let data = UIImageJPEGRepresentation(profile, 0.2){
                    let newImgUID = NSUUID().uuidString
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    let storageRef = Storage.storage().reference()
                    storageRef.child(imgUID!).delete(completion: nil)
                    let storageItem = storageRef.child(newImgUID)
                    print("putting new imgUID", newImgUID)
                    storageItem.putData(data, metadata: metaData){
                        (metaData, error) in
                        if error != nil {
                            print("upload error!")
                        }
                        else{
                            storageItem.downloadURL(completion: {(url, error) in
                                if error != nil{
                                    print("error uploading image!")
                                }
                                else{
                                    imageRef.child("userImg").setValue(url!.absoluteString)
                                    imageRef.child("imgUID").setValue(newImgUID)
                                    self.delegate.userImg = url!.absoluteString

                                }
                            })
                            
                            
                        }
                    }
                  
                }
            
            }
 
        })
        
    }
    
    
    
    
    // MARK: - Table view data source
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeEmail"{
            let vc = segue.destination as? ChangeCredentialsTVC
            vc?.isPassword = false
        }
        else if segue.identifier == "ChangePassword"{
            let vc = segue.destination as? ChangeCredentialsTVC
            vc?.isPassword = true
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
