// Copyright 2018 Alex Scown

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
