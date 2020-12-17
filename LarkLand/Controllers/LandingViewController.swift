//
//  LandingViewController.swift
//  LarkLand
//
//  Created by Hossein on 12/16/20.
//

import UIKit
import SpriteKit

class LandingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authenticateUserAndConfigureView()
    }
    
    func authenticateUserAndConfigureView() {
        if (currUser == nil) {
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.rootViewController =  UINavigationController(rootViewController: LogInViewController())
            }
        } else {
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.rootViewController =  UINavigationController(rootViewController: OfficeViewController())
            }
        }
    }
    

}
