// Copyright 2018 Alex Scown

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Cocoa

class PixelView: NSView {
    
    @IBOutlet var vram: VRam!
    
    override var isFlipped:Bool {
        get {
            return true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSColor.black.set()
        dirtyRect.fill()
        
        NSColor.white.set()
        
        let RES = vram.RES
        
        for row in Int(dirtyRect.minY) / RES ..< Int(ceil(Double(Int(dirtyRect.maxY) / RES))) {
            for col in Int(dirtyRect.minX) / RES ..< Int(ceil(Double(Int(dirtyRect.maxX) / RES))) {
                let isWhite = vram.pixels[row][col]
                
                if isWhite {
                    let square = NSRect.init(x: col * RES, y: row * RES, width: RES, height: RES)
                    square.fill()
                }
            }

        }
    }
    
}
