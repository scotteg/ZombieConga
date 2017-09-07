//
//  GameScene.swift
//  ZombieConga
//
//  Created by Scott Gardner on 9/2/17.
//  Copyright © 2017 Scott Gardner. All rights reserved.
//

import SpriteKit
import GameplayKit

final class GameScene: SKScene {
    
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    let movePointsPerSec: CGFloat = 480.0
    let cameraMovePointsPerSec: CGFloat = 200.0
    let rotateRadiansPerSec = 4.0 * CGFloat.pi
    var velocity = CGPoint.zero
    var lastTouchLocation: CGPoint?
    let enemyMoveDuration = 2.0
    var invincible = false
    var lives = 5
    var gameOver = false
    let flipHorizontalTransitionDuration: TimeInterval = 0.5
    
    let backgroundMusicPlayer: BackgroundMusicPlayer = {
        do {
            return try BackgroundMusicPlayer(filename: .backgroundMusic)
        } catch {
            print(error)
            fatalError()
        }
    }()
    
    let enemyCollisionSound = SKAction.playSoundFileNamed(.hitCatLady, waitForCompletion: false)
    let catCollisionSound = SKAction.playSoundFileNamed(.hitCat, waitForCompletion: false)
    
    lazy var playableRect: CGRect = {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        return CGRect(x: 0.0, y: playableMargin, width: size.width, height: playableHeight)
    }()
    
    lazy var zombie: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: .zombie1)
        node.position = CGPoint(x: 400, y: 400)
        node.setZPosition(.zombie)
        return node
    }()
    
    lazy var zombieAnimation: SKAction = {
        var textures = [SKTexture]()
        
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: Strings.zombie.rawValue + "\(i)"))
        }
        
        textures += [textures[2], textures[1]]
        return SKAction.animate(with: textures, timePerFrame: 0.1)
    }()
    
    var background: SKSpriteNode {
        let node = SKSpriteNode()
        node.name = Strings.background.rawValue
        node.anchorPoint = .zero
        node.position = .zero
        node.setZPosition(.background)

        let background1 = SKSpriteNode(imageNamed: .background1)
        background1.anchorPoint = .zero
        background1.position = .zero
        node.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: .background2)
        background2.anchorPoint = .zero
        background2.position = CGPoint(x: background1.size.width, y: 0.0)
        node.addChild(background2)
        
        node.size = CGSize(width: background1.size.width + background2.size.width, height: background1.size.height)
        return node
    }
    
    lazy var livesLabel: SKLabelNode = {
        let node = SKLabelNode(fontNamed: .glimstick)
        node.fontColor = .black
        node.fontSize = 100.0
        node.horizontalAlignmentMode = .left
        node.verticalAlignmentMode = .bottom
        node.position = CGPoint(x: -self.playableRect.size.halfWidth + 20.0, y: -self.playableRect.size.halfHeight + 20.0)
        node.setZPosition(.hud)
        return node
    }()
    
    lazy var catsLabel: SKLabelNode = {
        let node = SKLabelNode(fontNamed: .glimstick)
        node.fontColor = .black
        node.fontSize = 100.0
        node.horizontalAlignmentMode = .right
        node.verticalAlignmentMode = .bottom
        node.position = CGPoint(x: self.playableRect.size.halfWidth - 20.0, y: -self.playableRect.size.halfHeight + 20.0)
        node.setZPosition(.hud)
        return node
    }()
    
    var cameraRect: CGRect {
        guard let camera = camera else { return .zero }
        let x = camera.position.x - size.halfWidth + (size.width - playableRect.width) / 2.0
        let y = camera.position.y - size.halfHeight + (size.height - playableRect.height) / 2.0
        return CGRect(x: x, y: y, width: playableRect.width, height: playableRect.height)
    }
    
    override func didMove(to view: SKView) {
        configure()
        
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [weak self] in self?.spawnEnemy() },
            SKAction.wait(forDuration: enemyMoveDuration + 0.25)
        ])))
        
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [weak self] in self?.spawnCat() },
            SKAction.wait(forDuration: 1.0)
        ])))

        #if DEBUG
            if ProcessInfo.processInfo.environment[Strings.displayStats.rawValue] != nil {
                drawPlayableArea()
            }
        #endif
    }
    
    override func update(_ currentTime: TimeInterval) {
        dt = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0.0
        lastUpdateTime = currentTime
        
//        if let lastTouchLocation = lastTouchLocation,
//            (lastTouchLocation - zombie.position).length <= CGFloat(dt) * movePointsPerSec {
//            zombie.position = lastTouchLocation
//            velocity = .zero
//            stopZombieAnimation()
//        } else {
            move(zombie, velocity: velocity)
            rotate(zombie, direction: velocity)
//        }
        
        moveTrain()
        moveCamera()
        livesLabel.text = "Lives: \(self.lives)"
        
        if gameOver == false && lives < 1 {
            backgroundMusicPlayer.stop()
            gameOver = true
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: flipHorizontalTransitionDuration)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    override func didEvaluateActions() {
        checkZombieBounds()
        checkForCollisions()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        sceneTouched(location)
        lastTouchLocation = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        sceneTouched(touch.location(in: self))
    }
    
    func configure() {
        backgroundMusicPlayer.play()
        backgroundColor = .black
        
        for i in 0...1 {
            let background = self.background
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0.0)
            addChild(background)
        }
        
        addChild(zombie)
        
        let camera = SKCameraNode()
        addChild(camera)
        camera.position = CGPoint(x: size.halfWidth, y: size.halfHeight)
        camera.addChild(livesLabel)
        
        catsLabel.text = "Cats: 0"
        camera.addChild(catsLabel)
        
        self.camera = camera
    }
    
    func drawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = .red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func sceneTouched(_ location: CGPoint) {
        moveZombieToward(location)
    }
    
    func startZombieAnimation() {
        guard zombie.action(forKey: .animation) == nil else { return }
        zombie.run(SKAction.repeatForever(zombieAnimation), withKey: .animation)
    }
    
    func stopZombieAnimation() {
        zombie.removeAction(forKey: .animation)
    }
    
    func move(_ sprite: SKSpriteNode, velocity: CGPoint) {
        sprite.position += velocity * CGFloat(dt)
    }
    
    func moveZombieToward(_ location: CGPoint) {
        startZombieAnimation()
        let offset = location - zombie.position
        velocity = offset.normalized * movePointsPerSec
    }
    
    func moveCamera() {
        camera?.position += CGPoint(x: cameraMovePointsPerSec, y: 0.0) * CGFloat(dt)
        
        enumerateChildNodes(withName: .background) { [weak self] node, _ in
            guard let `self` = self,
                let background = node as? SKSpriteNode
                else { return }
            
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                background.position = CGPoint(x: background.position.x + background.size.width * 2.0, y: background.position.y)
            }
        }
    }
    
    func rotate(_ sprite: SKSpriteNode, direction: CGPoint) {
        let shortest = CGFloat.shortestAngleBetween(sprite.zRotation, and: velocity.angle)
        let rotation = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign * rotation
    }
    
    func checkZombieBounds() {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = abs(velocity.x)
            
            if velocity.x == 0 {
                startZombieAnimation()
            }
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
    
    func spawnEnemy() {
        let node = SKSpriteNode(imageNamed: .enemy)
        node.name = Strings.enemy.rawValue
        node.position = CGPoint(x: cameraRect.maxX + node.size.halfWidth, y: CGFloat.random(min: cameraRect.minY + node.size.halfHeight, max: cameraRect.maxY - node.size.halfHeight))
        node.setZPosition(.enemy)
        addChild(node)
        let move = SKAction.moveBy(x: -cameraRect.size.width, y: 0.0, duration: enemyMoveDuration)
        node.run(SKAction.sequence([move, SKAction.removeFromParent()]))
    }
    
    func spawnCat() {
        let node = SKSpriteNode(imageNamed: .cat)
        node.name = Strings.cat.rawValue
        node.position = CGPoint(x: CGFloat.random(min: cameraRect.minX, max: cameraRect.maxX), y: CGFloat.random(min: cameraRect.minY, max: cameraRect.maxY))
        node.setZPosition(.cat)
        node.setScale(0.0)
        addChild(node)
        
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let cycleScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        
        node.zRotation = -.pi / 16.0
        let leftWiggle = SKAction.rotate(byAngle: .pi / 8.0, duration: 0.5)
        let fullWiggle = SKAction.sequence([leftWiggle, leftWiggle.reversed()])
        
        let group = SKAction.group([cycleScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        
        let disappear = SKAction.scale(to: 0.0, duration: 0.5)
        let remove = SKAction.removeFromParent()
        node.run(SKAction.sequence([appear, groupWait, disappear, remove]))
    }
    
    func handleCollisionWith(enemy: SKSpriteNode) {
        guard invincible == false else { return }
        invincible = true
        run(enemyCollisionSound)
        loseCats()
        lives -= 1
        let wait = SKAction.wait(forDuration: 0.2)
        
        zombie.run(SKAction.repeat(SKAction.sequence([
            SKAction.hide(), wait,
            SKAction.unhide(), wait
        ]), count: 10)) { [weak self] in
            self?.invincible = false
        }
    }
    
    func loseCats() {
        var loseCount = 0
        
        enumerateChildNodes(withName: .train) { node, stop in
            var randomPosition = node.position
            randomPosition.x += CGFloat.random(min: -100.0, max: 100.0)
            randomPosition.y += CGFloat.random(min: -100.0, max: 100.0)
            
            node.name = nil
            
            node.run(SKAction.sequence([
                SKAction.group([
                    SKAction.rotate(byAngle: .pi * 4.0, duration: 1.0),
                    SKAction.move(to: randomPosition, duration: 1.0),
                    SKAction.scale(to: 0.0, duration: 1.0)
                ]),
                SKAction.removeFromParent()
            ]))
            
            loseCount += 1
            
            if loseCount >= 2 {
                stop[0] = true
            }
        }
    }
    
    func handleCollisionWith(cat: SKSpriteNode) {
        run(catCollisionSound)
        cat.name = Strings.train.rawValue
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation = 0.0
        cat.run(SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 0.2))
    }
    
    func checkForCollisions() {
        var enemies = [SKSpriteNode]()
        var cats = [SKSpriteNode]()
        
        enumerateChildNodes(withName: .enemy) { [weak self] node, _ in
            guard let `self` = self,
                let enemy = node as? SKSpriteNode,
                node.frame.insetBy(dx: 20.0, dy: 20.0).intersects(self.zombie.frame)
                else { return }
            
            enemies.append(enemy)
        }
        
        enumerateChildNodes(withName: .cat) { [weak self] node, _ in
            guard let `self` = self,
                let cat = node as? SKSpriteNode,
                node.frame.intersects(self.zombie.frame)
                else { return }
            
            cats.append(cat)
        }
        
        enemies.forEach { handleCollisionWith(enemy: $0) }
        cats.forEach { handleCollisionWith(cat: $0) }
    }
    
    func moveTrain() {
        var trainCount = 0
        var targetPosition = zombie.position
        let duration: TimeInterval = 0.3

        enumerateChildNodes(withName: .train) { node, _ in
            trainCount += 1
            
            if node.hasActions() == false {
                let move = (targetPosition - node.position).normalized * self.movePointsPerSec * CGFloat(duration)
                node.run(SKAction.moveBy(x: move.x, y: move.y, duration: duration))
//                node.run(SKAction.move(to: targetPosition, duration: duration))
            }
            
            targetPosition = node.position
        }
        
        print("trainCount = \(trainCount)")
        catsLabel.text = "Cats: \(trainCount)"
        
        if trainCount >= 15 && gameOver == false {
            backgroundMusicPlayer.stop()
            gameOver = true
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: flipHorizontalTransitionDuration)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
}
