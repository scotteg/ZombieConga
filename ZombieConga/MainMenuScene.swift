//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Scott Gardner on 6/16/15.
//  Copyright (c) 2015 Scott Gardner. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
  
  override func didMoveToView(view: SKView) {
    let background = SKSpriteNode(imageNamed: "MainMenu")
    background.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
    addChild(background)
  }
  
  #if os(iOS)
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    sceneTapped()
  }
  #else
  override func mouseDown(theEvent: NSEvent) {
    sceneTapped()
  }
  #endif
  
  func sceneTapped() {
    let gameScene = GameScene(size: size)
    gameScene.scaleMode = scaleMode
    let reveal = SKTransition.doorwayWithDuration(1.5)
    view?.presentScene(gameScene, transition: reveal)
  }
  
}
