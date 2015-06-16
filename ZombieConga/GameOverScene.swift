//
//  GameOverScene.swift
//  ZombieConga
//
//  Created by Scott Gardner on 6/16/15.
//  Copyright (c) 2015 Scott Gardner. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
  
  let won: Bool
  
  init(size: CGSize, won: Bool) {
    self.won = won
    super.init(size: size)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToView(view: SKView) {
    let background: SKSpriteNode
    
    if won {
      background = SKSpriteNode(imageNamed: "YouWin")
    } else {
      background = SKSpriteNode(imageNamed: "YouLose")
    }
    
    runActionForGameOver()
    background.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
    addChild(background)
    
    let wait = SKAction.waitForDuration(3.0)
    let block = SKAction.runBlock { [unowned self] in
      let myScene = GameScene(size: self.size)
      myScene.scaleMode = self.scaleMode
      let reveal = SKTransition.flipHorizontalWithDuration(0.5)
      self.view?.presentScene(myScene, transition: reveal)
    }
    
    runAction(SKAction.sequence([wait, block]))
  }
  
  func runActionForGameOver() {
    let soundFileName = won ? "win.wav" : "lose.wav"
    
    runAction(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.playSoundFileNamed(soundFileName, waitForCompletion: false)]))
  }
  
}
