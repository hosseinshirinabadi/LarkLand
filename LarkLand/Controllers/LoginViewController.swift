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
    
    func loadUserDict(completion: @escaping () -> Void) {
        let _ = db.collection("users").getDocuments() { (snap, error) in
            if let err = error {
                    print("Error getting documents: \(err)")
            } else {
                for document in snap!.documents {
                    let dbUser = document.data()
                    let name = dbUser["name"] as! String
                    if (name != currUser.userID) {
                        let name = dbUser["name"] as! String
                        let positionX = dbUser["positionX"] as! Float
                        let positionY = dbUser["positionY"] as! Float
                        let spriteCol = dbUser["spriteCol"] as! Int
                        let spriteRow = dbUser["spriteRow"] as! Int
                        userDict[name] = User(userID: name, name: name, positionX: positionX, positionY: positionY, spriteRow: spriteRow, spriteCol: spriteCol)
                        completion()
                    }
                }
            }
        }
    }
    
    @objc func logInPressed(_ sender: LoadingButton) {
        sender.tintColor = .white
        sender.showLoader(userInteraction: true)
        
        if let name = usernameTextField.text {
            currUser = User(userID: name, name: name)
            currUser.readFromDB {
                self.loadUserDict {
                    self.navigationController?.pushViewController(OfficeViewController(), animated: true)
                }
            }
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





