//
//  LogInViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 5/30/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit
import FacebookLogin

class LogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if let accessToken = acessToken.current {
            // User is logged in, use 'accessToken' here.
        //}
        
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends])
        loginButton.center = view.center
        
        view.addSubview(loginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
