//
//  AppDelegate.swift
//  ZombieCongaMac
//
//  Created by Scott Gardner on 6/16/15.
//  Copyright (c) 2015 Scott Gardner. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var skView: SKView!
  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    let scene = MainMenuScene(size: CGSize(width: 2048, height: 1536))
    scene.scaleMode = .AspectFit
    skView.presentScene(scene)
    skView.ignoresSiblingOrder = true
    skView.showsFPS = true
    skView.showsNodeCount = true
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
    return true
  }
}
