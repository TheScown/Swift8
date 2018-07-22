//
//  Timer.swift
//  Chip8
//
//  Created by Alexander Scown on 20/6/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa

class Timer: NSObject {
    @objc dynamic var delay: UInt8 = 0
    
    private let queue = DispatchQueue.main
    
    func reset() {
        delay = 0
    }
    
    func startTimer(x: UInt8) {
        queue.sync {
            self.delay = x
            
            self.queue.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.microseconds(16666)) {
                self.decrement()
            }
        }
    }
    
    private func decrement() {
        if (delay > 0) {
            delay -= 1

            self.queue.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.microseconds(16666)) {
                self.decrement()
            }
        }
    }
    
}
