//
//  User.swift
//  cycle
//
//  Created by boy setiawan on 14/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation
import Firebase

struct User{
    
    private var email:String
    private var password:String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
        
    }
    
    func signIn() -> Bool {
        
        var result = false
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error, user == nil {
                print(error.localizedDescription)
                result = false
            }else{
               result = true
            }
        }
        
        return result
        
        
    }
    
    func createAccount() -> Bool {
       
        var result = false
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil {
                result = true
            }
        }
        
        return result
    }
    
}
