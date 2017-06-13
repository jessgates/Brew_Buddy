//
//  LogInViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 5/30/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit
import Foundation
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn


class LogInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    @IBOutlet weak var bubbleView: BubbleView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Auth.auth().addStateDidChangeListener() { auth, user in
//            // 2
//            if user != nil {
//                // 3
//                self.showRootViewController()
//            }
//        }

        
        fbLoginButton?.delegate = self
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        //GIDSignIn.sharedInstance().signIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Failed to log into Google:", error)
        } else {
            print("Loged into Google user:", user)
            
            guard let idToken = user.authentication.idToken else { return }
            guard let accessToken = user.authentication.accessToken else { return }
            
            let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            print(credentials)
            
            Auth.auth().signIn(with: credentials, completion: { (user, error) in
                if let error = error {
                    print("Failed to create a Firebase User with a Google Account:", error)
                    return
                }
                self.showRootViewController()
            })
        }
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
            self.showRootViewController()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged out of Facebook")
    }
    
    func showRootViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
        self.present(vc, animated: true, completion: nil)
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
