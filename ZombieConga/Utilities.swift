//
//  Utilities.swift
//  ZombieConga
//
//  Created by Scott Gardner on 9/5/17.
//  Copyright © 2017 Scott Gardner. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

enum Strings: String {
    case animation, background, background1, background2, backgroundMusic = "backgroundMusic.mp3", cat, displayStats = "DISPLAY_STATS", enemy, glimstick = "Glimstick", hitCat = "hitCat.wav", hitCatLady = "hitCatLady.wav", loseSound = "lose.wav", mainMenu = "MainMenu", train, winSound = "win.wav", youLose = "YouLose", youWin = "YouWin", zombie, zombie1
}

extension SKLabelNode {
    
    convenience init(fontNamed fontName: Strings) {
        self.init(fontNamed: fontName.rawValue)
    }
}

enum ZPositions: CGFloat {
    case background = -1.0, cat = 50.0, enemy = 51.0, zombie = 100.0, hud = 150.0
}

extension SKNode {
    
    func setZPosition(_ value: ZPositions) {
        zPosition = value.rawValue
    }
}

extension CGFloat {
    
    var sign: CGFloat {
        return self >= 0.0 ? 1.0 : -1.0
    }
    
    static func shortestAngleBetween(_ left: CGFloat, and right: CGFloat) -> CGFloat {
        let pi = CGFloat.pi
        let twoPi = pi * 2.0
        var angle = (right - left).truncatingRemainder(dividingBy: twoPi)
        
        if angle >= pi {
            angle -= twoPi
        }
        
        if angle <= -pi {
            angle += twoPi
        }
        
        return angle
    }
    
    static func random(min: CGFloat = 0.0, max: CGFloat = CGFloat(UInt32.max)) -> CGFloat {
        precondition(min < max, "min must be less than max")
        return CGFloat(arc4random()) / CGFloat(UInt32.max) * (max - min) + min
    }
}

extension CGPoint {
    
    #if !(arch(x86_64) || arch(arm64))
    func atan2(y: CGFloat, x: CGFloat) -> CGFloat {
        return CGFloat(atan2f(Float(y), Float(x)))
    }
    
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
    #endif
    
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
    
    var normalized: CGPoint {
        return self / length
    }
    
    var angle: CGFloat {
        return atan2(y, x)
    }
    
    // Addition
    
    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func +=(left: inout CGPoint, right: CGPoint) {
        left = left + right
    }
    
    // Subtraction
    
    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func -=(left: inout CGPoint, right: CGPoint) {
        left = left - right
    }
    
    // Multiplication
    
    static func *(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x * right.x, y: left.y * right.y)
    }
    
    static func *=(left: inout CGPoint, right: CGPoint) {
        left = left * right
    }
    
    static func *(point: CGPoint, value: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * value, y: point.y * value)
    }
    
    static func *=(point: inout CGPoint, value: CGFloat) {
        point = point * value
    }
    
    // Division
    
    static func /(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x / right.x, y: left.y / right.y)
    }
    
    static func /=(left: inout CGPoint, right: CGPoint) {
        left = left / right
    }
    
    static func /(point: CGPoint, value: CGFloat) -> CGPoint {
        return CGPoint(x: point.x / value, y: point.y / value)
    }
    
    static func /=(point: inout CGPoint, value: CGFloat) {
        point = point / value
    }
}

extension CGSize {
    
    var halfWidth: CGFloat {
        return width / 2.0
    }
    
    var halfHeight: CGFloat {
        return height / 2.0
    }
}

extension CGRect {
    
    var halfWidth: CGFloat {
        return width / 2.0
    }
    
    var halfHeight: CGFloat {
        return height / 2.0
    }
}

extension SKNode {
    
    func enumerateChildNodes(withName name: Strings, using block: @escaping (SKNode, UnsafeMutablePointer<ObjCBool>) -> Void) {
        enumerateChildNodes(withName: name.rawValue, using: block)
    }
}

extension SKSpriteNode {
    
    convenience init(imageNamed name: Strings) {
        self.init(imageNamed: name.rawValue)
    }
    
    func action(forKey key: Strings) -> SKAction? {
        return action(forKey: key.rawValue)
    }
    
    func run(_ action: SKAction, withKey key: Strings) {
        run(action, withKey: key.rawValue)
    }
    
    func removeAction(forKey key: Strings) {
        removeAction(forKey: key.rawValue)
    }
}

extension SKAction {
    
    static func playSoundFileNamed(_ soundFile: Strings, waitForCompletion wait: Bool) -> SKAction {
        return playSoundFileNamed(soundFile.rawValue, waitForCompletion: wait)
    }
}
