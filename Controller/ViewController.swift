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
        
    }

    @IBAction func signIn(_ sender: UIButton) {
        
        Login.createAccount(email: textBoxUserID.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: textBoxPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { (info) in
            let alert = UIAlertController(title: "Welcome",message: info,preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    @IBAction func login(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "showMap", sender: nil )
        
//        Login.loginAccount(email: textBoxUserID.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: textBoxPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { (info,result) in
//
//            if result{
//                self.performSegue(withIdentifier: "showMap", sender: nil )
//            }else{
//                let alert = UIAlertController(title: "Login",message: info,preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true, completion: nil)
//            }
//
//
//        }
    }
    
}



