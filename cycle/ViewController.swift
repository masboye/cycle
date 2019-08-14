//
//  ViewController.swift
//  cycle
//
//  Created by boy setiawan on 12/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class ViewController: UIViewController {
    
    var ref: DatabaseReference!
    let emailField = "boye.setiawan@gmail.com"
    let passwordField = "masboye"
    
    @IBAction func login(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: emailField, password: passwordField) { user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Sign In Success",
                                              message: "Welcome",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func createAccount(_ sender: UIButton) {
       
        // 2
        Auth.auth().createUser(withEmail: emailField, password: passwordField) { user, error in
            if error == nil {
                let alert = UIAlertController(title: "Create User Success",
                                              message: "Welcome",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Create User Failed",
                                              message: error?.localizedDescription,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
       
    }
    
    @IBAction func readData(_ sender: UIButton) {
        
        ref.observe(.value, with: { snapshot in
            print(snapshot.value as Any)
        })
        
        print("\(ref.key) - \(ref.url)")
        
    }
    @IBAction func searchData(_ sender: UIButton) {
        
//        let strSearch = "m@sboye"
//
//        ref.child("users").queryOrdered(byChild:  "username").queryStarting(atValue: strSearch).queryEnding(atValue: strSearch + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
//
//            for item in snapshot.children{
//
//                let user = item as! DataSnapshot
//                //let pName = user.value!["username"] as! String
//                for field in user.children{
//                    let name = field as! DataSnapshot
//                    print(name.key)
//                }
//            }
//
//        })
        
        let strSearch2 = "jalan2kemonas"
        let cyclist = Activity()
        
        cyclist.searchActivity(activityID: strSearch2) { (activities) in
            for activity in activities{
                //update values
                //activity.ref?.updateChildValues(["activityID" : "testME"])
                print(activities)
            }
        }
    
    }
    
    @IBAction func insertData(_ sender: UIButton) {
        
        //self.ref.child("users").child("masboye").setValue(["username": "m@sboye"])
        
//        let streets = ["Albemarle", "Brandywine", "Chesapeake"]
//        //self.ref.child("users").child("masboye2").setValue(["username": "m@sboye","second value": streets])
//        self.ref.child("users").childByAutoId().setValue(["username": "m@sboye@kemlu.go.id","second value": streets])
//
        var routes = [CLLocationCoordinate2D(latitude:39.173209 , longitude: -94.593933)]
        routes.append(CLLocationCoordinate2D(latitude:39.173239 , longitude: -94.593999))
        var activity = Activity(id: "jalan2kemonas", routes: routes)
        
        activity.insertData { (info) in
            print(info)
        }
        
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
    }


}



