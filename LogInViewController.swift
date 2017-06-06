//
//  LogInViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 5/30/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn


class LogInViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if let accessToken = acessToken.current {
            // User is logged in, use 'accessToken' here.
        //}
        
        let FBloginButton = FBSDKLoginButton()
        FBloginButton.frame = CGRect(x: 16, y: 166, width: view.frame.width - 32, height: 50)
        FBloginButton.delegate = self
        
        view.addSubview(FBloginButton)
        
        //add Google Sign In button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 166 + 66, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Failed to create a Firebase User with a Facebook Account:", error)
            }
            print("Logged in with Facebook")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged out of Facebook")
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
