//
//  LoginViewController.swift
//  LarkLand
//
//  Created by Hossein on 12/16/20.
//

import Foundation
import UIKit
import Firebase
import MHLoadingButton

var currUser: User!
let db = Firestore.firestore()
let storage = Storage.storage()
var functions = Functions.functions()


class LogInViewController: UIViewController {

    var mainView = LogInView()
    var usernameTextField: UITextField!
    var logInButton: LoadingButton!
    
    var textFields = [UITextField]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mainView)
        view.backgroundColor = .black
        setupConstraints()
        
        logInButton = mainView.getButtonWithID(.logIn) as! LoadingButton
        usernameTextField = mainView.getTextFieldWithId(.username)
        textFields.append(usernameTextField)
        logInButton.addTarget(self, action: #selector(self.logInPressed), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LogInViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardFrame.height / 2
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    @objc func logInPressed(_ sender: LoadingButton) {
        sender.tintColor = .white
        sender.showLoader(userInteraction: true)
        if let name = usernameTextField.text {
            let userID = UUID().uuidString
            currUser = User(userID: name, name: name)
            self.navigationController?.pushViewController(LandingViewController(), animated: true)
        }
    }
    
    @objc func dismissKeyboard() {
        for item in textFields {
            item.resignFirstResponder()
        }
    }
}
    
// MARK: - Setting Constraints
extension LogInViewController {
    
    private func setupConstraints() {
    mainView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
            mainView.leftAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leftAnchor),
            mainView.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor),
            mainView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor),
            mainView.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}


extension LogInViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}





