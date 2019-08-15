//
//  Login.swift
//  cycle
//
//  Created by boy setiawan on 14/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation
import Firebase

struct Login{
    
    static func createAccount(email:String, password:String, callback: @escaping (String,Bool) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil {
                callback("Create User Success",true)
            }else{
                callback(error!.localizedDescription,false)
            }
        }
    }
    
    static func loginAccount(email:String, password:String, callback: @escaping (String,Bool) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error, user == nil {
                callback(error.localizedDescription,false)
            }else{
                callback("Welcome",true)
            }
        }
    }
    
}
