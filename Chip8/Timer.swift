//
//  Timer.swift
//  Chip8
//
//  Created by Alexander Scown on 20/6/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa

class Timer: NSObject {
    var delay: UInt8 = 0
    
    func reset() {
        delay = 0
    }
    
    func startTimer(x: UInt8) {
        delay = x
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.microseconds(16666)) {
            self.decrement()
        }
    }
    
    private func decrement() {
        delay -= 1
        
        if (delay > 0) {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(16)) {
                self.decrement()
            }
        }
    }
    
}
