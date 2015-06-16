//
//  MyUtils.swift
//  ZombieConga
//
//  Created by Scott Gardner on 6/15/15.
//  Copyright (c) 2015 Scott Gardner. All rights reserved.
//

import Foundation
import CoreGraphics

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (inout left: CGPoint, right: CGPoint) {
  left = left + right
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -= (inout left: CGPoint, right: CGPoint) {
  left = left - right
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *= (inout left: CGPoint, right: CGPoint) {
  left = left * right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func -= (inout point: CGPoint, scalar: CGFloat) {
  point = point * scalar
}

func / (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func /= (inout left: CGPoint, right: CGPoint) {
  left = left / right
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (inout point: CGPoint, scalar: CGFloat) {
  point = point / scalar
}

let π = CGFloat(M_PI)

func shortestAngleBetween(angle1: CGFloat, angle2: CGFloat) -> CGFloat {
  let twoπ = π * 2.0
  var angle = (angle2 - angle1) % twoπ
  
  if angle >= π {
    angle = angle - twoπ
  }
  
  if angle <= -π {
    angle = angle + twoπ
  }
  
  return angle
}

#if !(arch(x86_64) || arch(arm64))
  func atan2(y: CGFloat, x: CGFloat) -> CGFloat {
    return CGFloat(atan2f(Float(y), Float(x)))
  }
  
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

extension CGPoint {
  
  func length() -> CGFloat {
    return sqrt(x * x + y * y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
  
  var angle: CGFloat {
    return atan2(y, x)
  }
  
}

extension CGFloat {
  
  func sign() -> CGFloat {
    return self >= 0.0 ? 1.0 : -1.0
  }
  
  static func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(UInt32.max))
  }
  
  static func random(#min: CGFloat, max: CGFloat) -> CGFloat {
    assert(min < max)
    return CGFloat.random() * (max - min) + min
  }
  
}

import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
  let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
  
  if url == nil {
    println("Could not find file: \(filename)")
    return
  }
  
  var error: NSError?
  backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
  
  if backgroundMusicPlayer == nil {
    println("Could not create audio player: \(error!)")
    return
  }
  
  backgroundMusicPlayer.numberOfLoops = -1
  backgroundMusicPlayer.prepareToPlay()
  backgroundMusicPlayer.play()
}

