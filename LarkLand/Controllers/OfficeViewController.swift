//
//  OfficeViewController.swift
//  LarkLand
//
//  Created by Hossein on 12/16/20.
//

import UIKit
import SpriteKit

class OfficeViewController: UIViewController {
    var officeNameLabel: UILabel!
    
    override func loadView() {
        self.view = SKView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
//        officeNameLabel = UILabel()
//        officeNameLabel.text = Constants.officeName
//        self.view.addSubview(officeNameLabel)
//        setupConstraints()
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)

    }
    
    override var prefersStatusBarHidden: Bool {
      return true
    }
    
    
    func setupConstraints() {
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height //896
        let width = bounds.size.width // 414
        officeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            officeNameLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            officeNameLabel.topAnchor.constraint(equalTo: self.view.topAnchor),
            officeNameLabel.widthAnchor.constraint(equalToConstant: 200),
            officeNameLabel.heightAnchor.constraint(equalToConstant: 80),
         
        ])
    }

}
