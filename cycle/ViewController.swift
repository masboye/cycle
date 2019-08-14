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
    
    let email = "boye.setiawan@gmail.com"
    let password = "masboye"
    let activityName = "jalan2kemonas"
    let fullName = "boy setiawan"
    
    @IBAction func login(_ sender: UIButton) {
        
        Login.loginAccount(email: email, password: password) { (info) in
            let alert = UIAlertController(title: "Login",message: info,preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func createAccount(_ sender: UIButton) {
       
        Login.createAccount(email: email, password: password) { (info) in
        let alert = UIAlertController(title: "Welcome",message: info,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
        }
       
       
    }
    
    @IBAction func readData(_ sender: UIButton) {
        
//        ref.observe(.value, with: { snapshot in
//            print(snapshot.value as Any)
//        })
//        
//        print("\(ref.key) - \(ref.url)")
        
    }
    @IBAction func searchData(_ sender: UIButton) {
        
        let kegiatan = Activity()
        
        kegiatan.searchActivity(activityID: activityName) { (activities) in
            print(activities)
//            for activity in activities{
//                //update values
//                //activity.ref?.updateChildValues(["activityID" : "testME"])
//
//            }
        }
        
        let user = User()
        
        user.searchUser(userID: email) { (users) in
            print(users)
        }
    
    }
    
    @IBAction func insertData(_ sender: UIButton) {
       
        let user = User(id: email, fullName: fullName, activity: activityName, location: CLLocationCoordinate2D(latitude:39.173209 , longitude: -94.593933))
        user.insertData { (info) in
            print(info)
        }
        
        var routes = [CLLocationCoordinate2D(latitude:39.173209 , longitude: -94.593933)]
        routes.append(CLLocationCoordinate2D(latitude:39.173239 , longitude: -94.593999))
        let activity = Activity(id: "jalan2kemonas", routes: routes)
        
        activity.insertData { (info) in
            print(info)
        }
        
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }


}



