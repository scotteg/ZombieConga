//
//  BackgroundMusicPlayer.swift
//  ZombieConga
//
//  Created by Scott Gardner on 9/6/17.
//  Copyright © 2017 Scott Gardner. All rights reserved.
//

import AVFoundation

class BackgroundMusicPlayer: AVAudioPlayer {
    
    enum BMPError: Error {
        case fileNotFound
    }
    
    convenience init(filename: Strings) throws {
        guard let url = Bundle.main.url(forResource: filename.rawValue, withExtension: nil) else { throw BMPError.fileNotFound }
        
        try self.init(contentsOf: url)
        numberOfLoops = -1
        prepareToPlay()
    }
}
