//
//  ForgotPasswordVC.swift
//  SubMeet
//
//  Created by carlos arellano on 10/8/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var EmailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func Cancel(_ sender: AnyObject){
    dismiss(animated: true, completion: nil)
    
    
    }
    
    @IBAction func Submit(_ sender: AnyObject){
        if EmailField.text != ""{
            Auth.auth().sendPasswordReset(withEmail: EmailField.text!, completion: {(error) in
                if error != nil {
                print("Error sending password reset email!")
                }
                })
        dismiss(animated: true, completion: nil)
        
            
        }
        else{
            createAlert(title: "Please enter an email!", message: "Please enter the email you use to login to your account. We will send you a password reset email shortly.")
        }
    }
    func createAlert(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
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
