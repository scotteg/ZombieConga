//
//  GameScene.swift
//  ZombieConga
//
//  Created by Scott Gardner on 6/15/15.
//  Copyright (c) 2015 Scott Gardner. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
  
  let background = SKSpriteNode(imageNamed: "background1")
  let zombie = SKSpriteNode(imageNamed: "zombie1")
  var lastUpdateTime: NSTimeInterval = 0.0
  var deltaTime: NSTimeInterval = 0.0
  let zombieMovePointsPerSec: CGFloat = 480.0
  var velocity = CGPointZero
  let playableRect: CGRect
  var lastTouchLocation: CGPoint?
  let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
  let zombieAnimation: SKAction
  let catCollisionSound = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
  let enemyCollisionSound = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
  var zombieIsInvincible = false
  let catMovePointsPerSec: CGFloat = 480.0
  let catRotateRadiansPerSec: CGFloat = 4.0 * π
  var lives = 5
  var gameOver = false
  
  override init(size: CGSize) {
    let maxAspectRatio: CGFloat = 16.0 / 9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height - playableHeight) / 2.0
    playableRect = CGRect(x: 0.0, y: playableMargin, width: size.width, height: playableHeight)
    var textures = [SKTexture]()
    
    for i in 1...4 {
      textures.append(SKTexture(imageNamed: "zombie\(i)"))
    }
    
    textures.append(textures[2])
    textures.append(textures[1])
    zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
    zombie.zPosition = 100.0
      
    super.init(size: size)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToView(view: SKView) {
    playBackgroundMusic("backgroundMusic.mp3")
    backgroundColor = SKColor.whiteColor()
    background.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
    background.zPosition = -1
    addChild(background)
    
    zombie.position = CGPoint(x: 400, y: 400)
    addChild(zombie)
    runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy), SKAction.waitForDuration(2.0)])))
    runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat), SKAction.waitForDuration(1.0)])))
//    debugDrawPlayableArea()
  }
  
  override func update(currentTime: NSTimeInterval) {
    if lastUpdateTime > 0 {
      deltaTime = currentTime - lastUpdateTime
    } else {
      deltaTime = 0
    }
    
    lastUpdateTime = currentTime
//    println("\(deltaTime * 1000.0) milliseconds since last update")
    boundsCheckZombie()
    distanceCheckZombie()
    moveTrain()
    checkGameOver()
  }
  
  override func didEvaluateActions() {
    checkCollisions()
  }
  
  func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(deltaTime)
//    println("Amount to move: \(amountToMove)")
    sprite.position += amountToMove
  }
  
  func moveZombieToward(location: CGPoint) {
    startZombieAnimation()
    let offset = location - zombie.position
    let length = offset.length()
    let direction = offset.normalized()
    velocity = direction * zombieMovePointsPerSec
  }
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    processTouches(touches)
  }
  
  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    processTouches(touches)
  }
  
  func processTouches(touches: Set<NSObject>) {
    let touch = touches.first as! UITouch
    let location = touch.locationInNode(self)
    sceneTouched(location)
    lastTouchLocation = location
  }
  
  func sceneTouched(location: CGPoint) {
    moveZombieToward(location)
  }
  
  func boundsCheckZombie() {
    let bottomLeft = CGPoint(x: 0.0, y: CGRectGetMinY(playableRect))
    let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
    
    if zombie.position.x <= bottomLeft.x {
      zombie.position.x = bottomLeft.x
      velocity.x = -velocity.x
    }
    
    if zombie.position.x >= topRight.x {
      zombie.position.x = topRight.x
      velocity.x = -velocity.x
    }
    
    if zombie.position.y <= bottomLeft.y {
      zombie.position.y = bottomLeft.y
      velocity.y = -velocity.y
    }
    
    if zombie.position.y >= topRight.y {
      zombie.position.y = topRight.y
      velocity.y = -velocity.y
    }
  }
  
  func distanceCheckZombie() {
    if let lastTouchLocation = lastTouchLocation {
      let distance = (zombie.position - lastTouchLocation).length()
      
      if distance > zombieMovePointsPerSec * CGFloat(deltaTime) {
        moveSprite(zombie, velocity: velocity)
        rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
      } else {
        zombie.position = lastTouchLocation
        velocity = CGPointZero
        stopZombieAnimation()
      }
    }
  }
  
  func debugDrawPlayableArea() {
    let shape = SKShapeNode()
    let path = CGPathCreateMutable()
    CGPathAddRect(path, nil, playableRect)
    shape.path = path
    shape.strokeColor = SKColor.redColor()
    shape.lineWidth = 4.0
    addChild(shape)
  }
  
  func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
    // SOH CAH TOA
    // tan(angle) = opposite / adjacent
    let shortestAngle = shortestAngleBetween(zombie.zRotation, velocity.angle)
    let amountToRotate = min(rotateRadiansPerSec * CGFloat(deltaTime), abs(shortestAngle))
    sprite.zRotation += shortestAngle.sign() * amountToRotate
  }
  
  func spawnEnemy() {
    let enemy = SKSpriteNode(imageNamed: "enemy")
    enemy.name = "enemy"
    
    // Moves enemy back and forth in V path
//    enemy.position = CGPoint(x: size.width + enemy.size.width / 2.0, y: size.height / 2.0)
//    addChild(enemy)
//    let actionMidMove = SKAction.moveByX(-size.width / 2.0 - enemy.size.width / 2.0, y: -CGRectGetHeight(playableRect) / 2.0 + enemy.size.height / 2.0, duration: 1.0)
//    let actionMove = SKAction.moveByX(-size.width / 2.0 - enemy.size.width / 2.0, y: CGRectGetHeight(playableRect) / 2.0 - enemy.size.height / 2.0, duration: 1.0)
//    let wait = SKAction.waitForDuration(0.25)
//    let logMessage = SKAction.runBlock() {
//      println("Reached bottom!")
//    }
//    let halfSequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove])
//    let sequence = SKAction.sequence([halfSequence, halfSequence.reversedAction()])
//    let repeat = SKAction.repeatActionForever(sequence)
//    enemy.runAction(repeat)
    
    enemy.position = CGPoint(x: size.width + enemy.size.width / 2.0, y: CGFloat.random(min: CGRectGetMinY(playableRect) + enemy.size.height / 2.0, max: CGRectGetMaxY(playableRect) - enemy.size.height / 2.0))
    addChild(enemy)
    let actionMove = SKAction.moveToX(-enemy.size.width / 2.0, duration: 2.0)
    let actionRemove = SKAction.removeFromParent()
    enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
  }
  
  func startZombieAnimation() {
    if zombie.actionForKey("animation") == nil {
      zombie.runAction(SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
    }
  }
  
  func stopZombieAnimation() {
    zombie.removeActionForKey("animation")
  }
  
  func spawnCat() {
    let cat = SKSpriteNode(imageNamed: "cat")
    cat.name = "cat"
    cat.position = CGPoint(x: CGFloat.random(min: CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)), y: CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect)))
    cat.setScale(0.0)
    addChild(cat)
    let appear = SKAction.scaleTo(1.0, duration: 0.5)
    cat.zRotation = -π / 16.0
    let leftWiggle = SKAction.rotateByAngle(π / 8.0, duration: 0.5)
    let rightWiggle = leftWiggle.reversedAction()
    let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
    
    let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
    let scaleDown = scaleUp.reversedAction()
    let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
    let group = SKAction.group([fullScale, fullWiggle])
    let groupWait = SKAction.repeatAction(group, count: 10)
    
    let disappear = SKAction.scaleTo(0.0, duration: 0.5)
    let removeFromParent = SKAction.removeFromParent()
    let actions = [appear, groupWait, disappear, removeFromParent]
    cat.runAction(SKAction.sequence(actions))
  }
  
  func checkCollisions() {
    var hitCats = [SKSpriteNode]()
    
    enumerateChildNodesWithName("cat") { [unowned self] (node, _) in
      let cat = node as! SKSpriteNode
      
      if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
        hitCats.append(cat)
      }
    }
    
    for cat in hitCats {
      zombieHitCat(cat)
    }
    
    var hitEnemies = [SKSpriteNode]()
    
    if zombieIsInvincible == false {
      enumerateChildNodesWithName("enemy") { [unowned self] (node, _) in
        let enemy = node as! SKSpriteNode
        
        if CGRectIntersectsRect(CGRectInset(node.frame, 20.0, 20.0), self.zombie.frame) {
          hitEnemies.append(enemy)
        }
      }
      
      for enemy in hitEnemies {
        zombieHitEnemy(enemy)
      }
    }
  }
  
  func zombieHitEnemy(enemy: SKSpriteNode) {
    zombieIsInvincible = true
    runAction(enemyCollisionSound)
    loseCats()
    lives--
    
    let blinkTimes = 10.0
    let duration = 3.0
    let blinkAction = SKAction.customActionWithDuration(duration) { (node, elapsedTime) in
      let slice = duration / blinkTimes
      let remainder = Double(elapsedTime) % slice
      node.hidden = remainder > slice / 2.0
    }
    
    zombie.runAction(blinkAction) { [unowned self] in
      self.zombie.hidden = false
      self.zombieIsInvincible = false
    }
  }
  
  func zombieHitCat(cat: SKSpriteNode) {
    runAction(catCollisionSound)
    cat.name = "train"
    cat.removeAllActions()
    cat.setScale(1.0)
    rotateSprite(cat, direction: CGPointZero, rotateRadiansPerSec: catRotateRadiansPerSec)
    colorizeCat(cat)
  }
  
  func colorizeCat(cat: SKSpriteNode) {
    cat.runAction(SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2))
  }
  
  func moveTrain() {
    var targetPosition = zombie.position
    var trainCount = 0
    
    enumerateChildNodesWithName("train") { [unowned self] (node, _) in
      trainCount++
      
      if node.hasActions() == false {
        let actionDuration = 0.3
        let offset = targetPosition - node.position
        let direction = offset.normalized()
        let amountToMovePerSec = direction * self.catMovePointsPerSec
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
        let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
        node.runAction(moveAction)
      }
      
      targetPosition = node.position
    }
    
    if trainCount >= 30 && gameOver == false {
      gameOver = true
      showGameOverScene(won: true)
    }
  }
  
  func showGameOverScene(#won: Bool) {
    let gameOverScene = GameOverScene(size: size, won: won)
    gameOverScene.scaleMode = scaleMode
    let reveal = SKTransition.flipHorizontalWithDuration(0.5)
    backgroundMusicPlayer.stop()
    view?.presentScene(gameOverScene, transition: reveal)
  }
  
  func loseCats() {
    var loseCount = 0
    
    enumerateChildNodesWithName("train") { (node, stop) in
      var randomSpot = node.position
      randomSpot.x += CGFloat.random(min: -100.0, max: 100.0)
      randomSpot.y += CGFloat.random(min: -100.0, max: 100.0)
      node.name = ""
      
      node.runAction(SKAction.sequence([SKAction.group([
        SKAction.rotateByAngle(π * 4.0, duration: 1.0),
        SKAction.moveTo(randomSpot, duration: 1.0),
        SKAction.scaleTo(0.0, duration: 1.0)
      ]),
        SKAction.removeFromParent()
      ]))
      
      loseCount++
      
      if loseCount >= 2 {
        stop.memory = true
      }
    }
  }
  
  func checkGameOver() {
    if lives <= 0 && gameOver == false {
      gameOver = true
      showGameOverScene(won: false)
    }
  }
  
}
