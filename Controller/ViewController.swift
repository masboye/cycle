//
//  ViewController.swift
//  cycle
//
//  Created by boy setiawan on 12/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textBoxPassword: UITextField!
    @IBOutlet weak var textBoxUserID: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        let userID = defaults.string(forKey: "email")
        self.textBoxUserID.text = userID
//
//        let user = User()
//        
//        user.searchUser(userID: userID ?? "") { (users) in
//            //already sign in
//            self.performSegue(withIdentifier: "showMap", sender: nil )
//        }
    }

    @IBAction func signIn(_ sender: UIButton) {
        
        Login.createAccount(email: textBoxUserID.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: textBoxPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { (info,status) in
            
            
            if status{
                self.showInputDialog()
                
            }else{
                
                let alert = UIAlertController(title: "Welcome",message: info,preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    func showInputDialog() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Enter Name", message: "Enter your name", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            
            //getting the input values from user
            let name = alertController.textFields?[0].text
            let user = User(id: self.textBoxUserID.text!.trimmingCharacters(in: .whitespacesAndNewlines), fullName: name ?? self.textBoxUserID.text!.trimmingCharacters(in: .whitespacesAndNewlines), activity: "", location: CLLocationCoordinate2D(latitude:0.0 , longitude: 0.0))
            user.insertData { (info) in
                print(info)
            }
            let defaults = UserDefaults.standard
            defaults.set(self.textBoxUserID.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "email")
            self.performSegue(withIdentifier: "showMap", sender: nil )
        }
        
//        //the cancel action doing nothing
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
//
//
//        }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Name"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        //alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func login(_ sender: UIButton) {
        
        Login.loginAccount(email: textBoxUserID.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: textBoxPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { (info,result) in

            if result{
                let defaults = UserDefaults.standard
                defaults.set(self.textBoxUserID.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "email")
                self.performSegue(withIdentifier: "showMap", sender: nil )
            }else{
                let alert = UIAlertController(title: "Login",message: info,preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }


        }
    }
    
}



