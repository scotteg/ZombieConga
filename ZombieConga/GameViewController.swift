//
//  GameViewController.swift
//  ZombieConga
//
//  Created by Scott Gardner on 9/2/17.
//  Copyright © 2017 Scott Gardner. All rights reserved.
//

import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let skView = view as? SKView else { return }
        skView.ignoresSiblingOrder = true
        
        #if DEBUG
            if ProcessInfo.processInfo.environment["DISPLAY_STATS"] != nil {
                displayStats(in: skView)
            }
        #endif
        
        let scene = MainMenuScene(size: CGSize(width: 2048, height: 1536))
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    
    func displayStats(in skView: SKView) {
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.showsQuadCount = true
        skView.showsFPS = true
        skView.showsPhysics = true
        skView.showsFields = true
    }
}
