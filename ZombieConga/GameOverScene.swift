//
//  GameOverScene.swift
//  ZombieConga
//
//  Created by Scott Gardner on 9/6/17.
//  Copyright © 2017 Scott Gardner. All rights reserved.
//

import Foundation
import SpriteKit

final class GameOverScene: SKScene {
    
    let won: Bool
    
    init(size: CGSize, won: Bool) {
        self.won = won
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let background: SKSpriteNode
        let soundName: Strings
        
        if won {
            background = SKSpriteNode(imageNamed: Strings.youWin)
            soundName = Strings.winSound
        } else {
            background = SKSpriteNode(imageNamed: Strings.youLose)
            soundName = Strings.loseSound
        }
        
        background.position = CGPoint(x: size.halfWidth, y: size.halfHeight)
        addChild(background)
        
        run(SKAction.playSoundFileNamed(soundName, waitForCompletion: false))
        
        let wait = SKAction.wait(forDuration: 3.0)
        
        let block = SKAction.run { [weak self] in
            guard let `self` = self else { return }
            let gameScene = GameScene(size: self.size)
            gameScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: gameScene.flipHorizontalTransitionDuration)
            self.view?.presentScene(gameScene, transition: reveal)
        }
        
        run(SKAction.sequence([wait, block]))
    }
}
