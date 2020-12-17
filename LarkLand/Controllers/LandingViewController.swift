//
//  LandingViewController.swift
//  LarkLand
//
//  Created by Hossein on 12/16/20.
//

import UIKit
import SpriteKit
var currUser: User!


class LandingViewController: UIViewController {
    
    override func loadView() {
        self.view = SKView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        var officeName: UILabel!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
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

}
