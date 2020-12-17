//
//  LoginView.swift
//  LarkLand
//
//  Created by Hossein on 12/16/20.
//

import Foundation
import UIKit
import MHLoadingButton


class LogInView: UIView {

    enum LogInViewTextFields: String {
        case username = "usernameTextField"
    }

    public enum LogInViewButtons: String {
        case logIn = "logInButton"
    }
   

    var views = [String: UIView]()
    var logInButton: UIButton?
    var usernameTextField: UITextField?
    var usernameLabel: UILabel?
    var usernameStackView: UIStackView?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViewComponents()
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
// MARK: - Creating subviews
extension LogInView {
    func createViewComponents() {
        
        logInButton = {
            let button = LoadingButton(frame: .zero, icon: nil, text: "Log In", textColor: .white, font: UIFont(name: "Avenir-Heavy", size: 17), bgColor: UIColor.blue, cornerRadius: 20, withShadow: true)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.indicator = BallPulseSyncIndicator(color: .black)
            button.indicator.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
            button.indicator.backgroundColor = .systemTeal
            return button
        }()
        
        usernameLabel = {
            let label = UILabel()
            label.text = "Name"
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            return label
        }()
        
        usernameTextField = makeTextField(withPlaceholder: "name", textColor: .black)
        
        
        views["logInButton"] = logInButton
        views["usernameTextField"] = usernameTextField
        views["usernameLabel"] =  usernameLabel
    }
    
    func makeTextField(withPlaceholder text: String, textColor color: UIColor) -> UITextField {
        
        let textField = UITextField()
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
        textField.autocapitalizationType = .none
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.font = UIFont(name: "Avenir-Roman", size: 17)
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 10.0
        textField.attributedPlaceholder =  NSAttributedString(string: text, attributes: [.foregroundColor : color.withAlphaComponent(0.5)])
        textField.textColor = color
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    
    func setupView() {
        backgroundColor = .white
        for (_, val) in views {
            self.addSubview(val)
        }
    }
    
    func setupStackView(_ stackview: UIStackView, _ axis: NSLayoutConstraint.Axis) {
        stackview.axis = axis
        stackview.distribution = .fillProportionally
        stackview.alignment = .leading
        stackview.spacing = 0
        stackview.translatesAutoresizingMaskIntoConstraints = false
    }
}

// MARK: - Providing Access to TextFields and Buttons
extension LogInView {
    
    public func getTextFieldWithId(_ identifier: LogInViewTextFields) -> UITextField {
        return views["\(identifier.rawValue)"] as! UITextField
    }
    public func getButtonWithID(_ identifier: LogInViewButtons) -> UIButton {
        return views["\(identifier.rawValue)"] as! UIButton
    }
}

// MARK: - Setup Constraints
extension LogInView {
    func setupConstraints() {
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height //896
        let width = bounds.size.width // 414
        print(height)
        print(width)
        NSLayoutConstraint.activate([
            
         
         logInButton!.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            logInButton!.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -0.22 * height),
         logInButton!.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
         logInButton!.widthAnchor.constraint(equalToConstant: 0.75 * width),
            logInButton!.heightAnchor.constraint(equalToConstant: 0.05 * height),
         
         usernameTextField!.widthAnchor.constraint(equalToConstant: 0.8 * width),
         usernameTextField!.heightAnchor.constraint(equalToConstant: height * (45 / height)),
         usernameTextField!.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -0.022 * height),
         usernameTextField!.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
         usernameLabel!.leadingAnchor.constraint(equalTo: usernameTextField!.leadingAnchor, constant: 0),
         usernameLabel!.bottomAnchor.constraint(equalTo: usernameTextField!.topAnchor, constant: -0.00565 * height),
         
        ])
    }
}

// MARK: - Extension of UITextField to allow space between text and bounds
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
}

// MARK: - Extension of UIButton to animate
extension UIButton  {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.3, animations: {
            self.transform  = CGAffineTransform.identity
        })
        
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 8, options: .allowUserInteraction, animations: {
//            self.transform  = CGAffineTransform.identity
//        }, completion: nil)
        
        super.touchesBegan(touches, with: event)
        
    }
}

