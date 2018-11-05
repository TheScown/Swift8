// Copyright 2018 Alex Scown

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Cocoa

class VRam: NSObject {
    let RES = 8
    
    weak var pixelView: PixelView?
    
    var pixels = Array(repeating: Array(repeating: false, count: 64), count: 32)
    
    func drawSprite(_ sprite: [UInt8], atRow: Int, andColumn: Int) -> Bool {
        let bitRows = sprite.map(byteToPixels)
        var returnValue = false
        
        for (r, bitRow) in bitRows.enumerated() {
            let row: Int = (atRow + r)
            
            if row < 32 {
                for (c, b) in bitRow.enumerated() {
                    let col: Int = (andColumn + c) % 64
                    let oldValue = pixels[row][col]
                    
                    if (oldValue && b) {
                        returnValue = true
                    }
                    
                    pixels[row][col] = oldValue != b
                    
                    pixelView!.setNeedsDisplay(NSRect(x: col * RES, y: row * RES, width: RES, height: RES))
                }
            }
        }
        
        return returnValue
    }
    
    func clear() {
        pixels = Array(repeating: Array(repeating: false, count: 64), count: 32)
        
        pixelView!.needsDisplay = true
    }
    
    private func byteToPixels(_ b: UInt8) -> [Bool] {
        let pixels: [Bool] = [
            b & 128 != 0,
            b & 64 != 0,
            b & 32 != 0,
            b & 16 != 0,
            b & 8 != 0,
            b & 4 != 0,
            b & 2 != 0,
            b & 1 != 0
        ]
        
        return pixels
    }
}
