//
//  registrationViewController.swift
//  GeoFence
//
//  Created by Kendall Lewis on 4/11/19.
//  Copyright © 2019 Kendall Lewis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FBSDKLoginKit


class registrationViewController: UIViewController, UITextFieldDelegate { //FBSDKLoginButtonDelegate {
    
    /************************* Login Page Connectors ***************************/
    @IBOutlet weak var usernameField: UITextField! //username field
    @IBOutlet weak var passwordField: UITextField! //password field
    @IBOutlet weak var loginButton: UIButton! //Login button
    @IBOutlet weak var registerButton: UIButton! //register button
    @IBOutlet weak var facebookButton: UIButton! //facebook button
    
    /*********************** Register Page Connectors **************************/
    @IBOutlet weak var registerUsernameField: UITextField!
    @IBOutlet weak var registerEmailField: UITextField!
    @IBOutlet weak var registerPasswordField: UITextField!
    @IBOutlet weak var registerConfirmPasswordField: UITextField!
    
    /*********************** Register Page Connectors **************************/
    @IBOutlet weak var resetPasswordField: UITextField!
    @IBOutlet weak var resetConfirmPasswordField: UITextField!
    @IBOutlet weak var resetEmailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true) //hide back button
        /*let loginButton = FBSDKLoginButton()
        facebookButton.addSubview(loginButton)
        */
        
    }
    @IBAction func loginButton(_ sender: Any) {
        if usernameField.text == "" { //use username for email/search for email with password
            let alertController = UIAlertController(title: "Error", message: "Please enter an email.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else if passwordField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter an password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().signIn(withEmail: usernameField.text!, password: passwordField.text!) { (user, error) in
                if error == nil {
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    activeUser = true //set the active user to false
                    /*< -----set user defualts to remember activeUser----->*/
                    UserDefaults.standard.set(true, forKey: "activeUser")
                    UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "activeUserID")
                    userID = String(Auth.auth().currentUser!.uid)
                    print(userID)
                    activeUser = true //set the active user to false
                    self.performSegue(withIdentifier: "loginToIntro", sender: nil)
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func registerButton(_ sender: Any) {
        if registerPasswordField.text! != registerConfirmPasswordField.text! {
            let alertController = UIAlertController(title: "Error", message: "Please enter matcing password and confirmation password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction) //add default action to alert
            present(alertController, animated: true, completion: nil) //show alert
        } else if registerUsernameField.text! == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your username", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction) //add default action to alert
            present(alertController, animated: true, completion: nil) //show alert
        } else if registerEmailField.text! == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction) //add default action to alert
            present(alertController, animated: true, completion: nil) //show alert
        } else if registerPasswordField.text! == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction) //add default action to alert
            present(alertController, animated: true, completion: nil) //show alert
        } else if registerConfirmPasswordField.text! == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your confirmation password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction) //add default action to alert
            present(alertController, animated: true, completion: nil) //show alert
        } else {
            Auth.auth().createUser(withEmail: registerEmailField.text!, password: registerPasswordField.text!) { (user, error) in
                if error == nil {
                    activeUser = true //set the active user to false
                    self.performSegue(withIdentifier: "registerToIntro", sender: nil) //segue to main
                    /*< -----set user defualts to remember activeUser----->*/
                    UserDefaults.standard.set(true, forKey: "activeUser")
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func resetPasswordButton(_ sender: Any) {
        if resetPasswordField.text != resetConfirmPasswordField.text {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter matching passwords.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        } else if resetEmailField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter your email.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        } else if resetPasswordField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter your password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        } else if resetConfirmPasswordField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter your confirm password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().sendPasswordReset(withEmail: resetEmailField.text!, completion: { (error) in
            var title = ""
            var message = ""
                if error != nil {
                title = "Error!"
                message = (error?.localizedDescription)!
            } else {
                title = "Success!"
                message = "Password reset email sent."
                    self.resetEmailField.text = ""
            }
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            })
        }
    }
    @IBAction func facebookLogin(_ sender: Any) {
        let LoginMan = LoginManager()
        LoginMan.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            print(credential.provider)
            // Perform login by calling Firebase APIs
            Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                //Print into the console if successfully logged in
                print("You have successfully logged in")
                activeUser = true //set the active user to false
                /*< -----set user defualts to remember activeUser----->*/
                UserDefaults.standard.set(true, forKey: "activeUser")
                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "activeUserID")
                userID = String(Auth.auth().currentUser!.uid)
                print(userID)
                activeUser = true //set the active user to false
                self.performSegue(withIdentifier: "loginToIntro", sender: nil)
            }
        }
    }
    //Hide keyboard when the users touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(usernameTextField: UITextField) -> Bool {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        registerEmailField.resignFirstResponder()
        registerUsernameField.resignFirstResponder()
        registerPasswordField.resignFirstResponder()
        registerConfirmPasswordField.resignFirstResponder()
        return true;
    }
}
