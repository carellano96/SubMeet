//
//  ChangeCredentialsTVC.swift
//  SubMeet
//
//  Created by carlos arellano on 10/8/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChangeCredentialsTVC: UITableViewController {

    @IBOutlet weak var CurrentLabel: UILabel!
    @IBOutlet weak var NewLabel: UILabel!
    @IBOutlet weak var CurrentText: UITextField!
    @IBOutlet weak var NewText: UITextField!
    var isPassword: Bool!
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("isPassword:",isPassword)
        if isPassword{
        CurrentLabel.text = "Please enter your current password:"
        NewLabel.text = "Please enter your new password:"
        CurrentText.isSecureTextEntry = true
        }
        else{
        CurrentLabel.text = "Please enter your current email:"
        NewLabel.text = "Please enter your new email:"
        CurrentText.isSecureTextEntry = false

        }
    }
    
    
    @IBAction func Save(_ sender: AnyObject){
        if CurrentText.text != "" && NewText.text != ""{
            if isPassword{
                changePassword(currentPassword: CurrentText.text!, newPassword: NewText.text!)
                
            }else{
                changeEmail(currentEmail: CurrentText.text!, newEmail: NewText.text!)
            }
        }
        else{
            createAlert(title: "Error", message: "There has been an error in your request. Please try again later.")
        }
    
    }
    
    func changeEmail( currentEmail: String, newEmail: String){
        let user = Auth.auth().currentUser
        let realEmail = user?.email
        if currentEmail == realEmail {
            user?.updateEmail(to: newEmail, completion: {(error) in
                
                if error != nil{
                    self.createAlert(title: "Unknown Error", message: "There has been an error. Please try again later!")
                }
            })
            
        }
        
        else{
            
            createAlert(title: "Incorrect email!", message: "You have inputted the incorrect current email! Please try again.")
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String){
            let user = Auth.auth().currentUser
            var email: String?;
            
            if (user != nil){
                email  = user?.email
            }
            let credential = EmailAuthProvider.credential(withEmail: email!, password: currentPassword)
            user?.reauthenticate(with: credential, completion: {(error) in
                if error != nil {
                    self.createAlert(title: "Incorrect Password", message: "You have inputted an incorrect password! Please try again!")
                    
                }
                else{
                    
                    user?.updatePassword(to: newPassword, completion: {(error) in
                        
                        if error != nil {
                            self.createAlert(title: "Error Updating Password!", message: "There has been an error updating your password. Please try again later.")
                        }
                    })
                }
                
            })
        
        
        
    }
    
    func createAlert(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

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
