//
//  SignUpViewController.swift
//  MyEvents
//
//  Created by ouali on 22/12/2019.
//  Copyright © 2019 Ouali Cherikh. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import Foundation

class SignUpViewController: UIViewController {
    
    //Outlet
    @IBOutlet var SignUpButton: UIButton!
    
    @IBOutlet var LoginButton: UIButton!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var ErrorLabel: UILabel!
    
    //Properties
    @IBOutlet weak var userRole: RadioButton!
    
    @IBOutlet weak var OrgRole: RadioButton!
    var role: String!

    override func awakeFromNib() {
        self.view.layoutIfNeeded()
        userRole.isSelected = true
        OrgRole.isSelected = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        setupTextFieldManager()
        ErrorLabel.alpha = 0
        userRole?.alternateButton = [OrgRole!]
        OrgRole?.alternateButton = [userRole!]
    }
    // private function
    private func setupButton() {
        SignUpButton.layer.cornerRadius = 20
        LoginButton.layer.cornerRadius = 20
        LoginButton.layer.borderWidth = 3
        LoginButton.layer.borderColor = UIColor.red.cgColor
    }
    private func setupTextFieldManager() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    // Action
    @objc private func hideKeyboard(){
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    func valedateFields() -> String? {
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        // check that all fields are filled in
        if username == "" && email == "" && password == "" {
                return "Erreur : les champs ne sont pas complets"
        }
        return nil
    }
    
    @IBAction func touchToSignUp(_ sender: Any) {

        guard let utilisateur = (userRole) else { return }
        guard let organisateur = (OrgRole) else { return }
        
        if utilisateur.isSelected == true {
            self.role = "Utilisateur"
        } else if organisateur.isSelected == true {
            self.role = "Organisateur"
        } else {
            self.role = "Utilisateur"
        }
        
        let error = valedateFields()
        
        if error != nil && role != nil {
            showError(error!)
        } else {
           
            let firstname = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
         
            Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
                guard let userID = Auth.auth().currentUser?.uid else { return }
                let db = Firestore.firestore()
                
                db.collection("users").document(userID).setData([
                            "firstname": firstname,
                            "lastname": "",
                            "email": email,
                            "uid": userID,
                            "phone": "",
                            "role": self.role
                ]) { (err) in
                        if err != nil {
                            self.showError("error saveing data user")
                        } else {
                            print("Inscription de \(firstname)")
                            print("Document added with ID: \(userID)")
                            self.transitionToHomeEvent()
                        }
                    }
                
                
                
            }
        }
    }
    
    @IBAction func touchToLogin(_ sender: Any) {
        guard let navigationView = self.navigationController?.view else {
            return
        }
        UIView.transition(with: navigationView, duration: 0.5, options: .transitionFlipFromTop, animations: {
        self.navigationController?.pushViewController(LoginViewController(), animated: true)
        })
    }
    func showError(_ message:String) {
        ErrorLabel.text = message
        ErrorLabel.alpha = 1
    }
    func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    func transitionToHomeEvent() {
        let alertController = UIAlertController(title: nil, message: "User was sucessfully created", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)

        let webViewOrg = HomeEventsOrgViewController()
        view.window?.rootViewController = webViewOrg
        view.window?.makeKeyAndVisible()
        
  
    }
    
}
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
