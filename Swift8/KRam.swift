// Copyright 2018 Alex Scown

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Cocoa

class KRam: NSObject {

    let queue = DispatchQueue(label: "space.scown.chip8", qos: .utility)
    
    var keyHandler: ((UInt8) -> ())?
    
    var keys = Array(repeating: false, count: 16)
    
    let keyValues: Dictionary<String, UInt8> = [
        "1": 1,
        "2": 2,
        "3": 3,
        "4": 0xC,
        "q": 4,
        "w": 5,
        "e": 6,
        "r": 0xD,
        "a": 7,
        "s": 8,
        "d": 9,
        "f": 0xE,
        "z": 0xA,
        "x": 0,
        "c": 0xB,
        "v": 0xF
    ]
    
    func keyDown(with event: NSEvent) {
        if let string = event.charactersIgnoringModifiers {
            queue.async {
                self.setKeys(string, true)
            }
        }
    }
    
    func keyUp(with event: NSEvent) {
        if let string = event.charactersIgnoringModifiers {
            queue.async {
                self.setKeys(string, false)
            }
        }
    }
    
    private func setKeys(_ string: String, _ flag: Bool) {
        for key in string {
            if let keyByte = keyValues[String(key)] {
                keys[Int(keyByte)] = flag
                
                if flag {
                    if let keyHandler = self.keyHandler {
                        keyHandler(keyByte)
                        
                        self.keyHandler = nil
                    }
                }
            }
        }
    }
    
}
