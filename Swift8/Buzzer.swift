//
//  Buzzer.swift
//  Chip8
//
//  Created by Alexander Scown on 20/6/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa
import AVFoundation

class Buzzer: NSObject {
    @objc dynamic var sound: UInt8 = 0
    
    private let queue = DispatchQueue.main
    
    let player: AVAudioPlayer
    
    override init() {
        let path: String? = Bundle.main.path(forResource: "440", ofType: "wav")
        
        do {
            try player = AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: path!))
            player.numberOfLoops = -1
        } catch {
            player = AVAudioPlayer()
        }
        
        player.prepareToPlay()
    }
    
    func reset() {
        sound = 0
    }
    
    func terminate() {
        sound = 0

        self.player.pause()
    }
    
    func startTimer(x: UInt8) {
        queue.sync {
            sound = x
            
            if (x > 0) {
                self.player.play()
            }
            
            queue.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.microseconds(16666)) {
                self.decrement()
            }
        }
    }
    
    private func decrement() {
        if (sound > 0) {
            sound -= 1
            
            queue.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.microseconds(16666)) {
                self.decrement()
            }
        }
        else {
            self.player.pause()
        }
    }
    
}
