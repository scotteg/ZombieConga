//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Scott Gardner on 9/6/17.
//  Copyright © 2017 Scott Gardner. All rights reserved.
//

import Foundation
import SpriteKit

final class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: .mainMenu)
        background.position = CGPoint(x: size.halfWidth, y: size.halfHeight)
        addChild(background)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        let reveal = SKTransition.doorway(withDuration: 1.5)
        self.view?.presentScene(gameScene, transition: reveal)
    }
}
