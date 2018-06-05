//
//  PixelView.swift
//  Chip8
//
//  Created by Alexander Scown on 31/5/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa

class PixelView: NSView {

    let RES = 8
    
    var pixels = Array(repeating: Array(repeating: false, count: 64), count: 32)

    override var isFlipped:Bool {
        get {
            return true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSColor.white.set()
        self.bounds.fill()
        
        for row in Int(self.bounds.minY) / RES ..< Int(self.bounds.maxY) / RES {
            for col in Int(self.bounds.minX) / RES ..< Int(self.bounds.maxX) / RES {
                let isBlack = pixels[row][col]
                let square = NSRect.init(x: col * RES, y: row * RES, width: RES, height: RES)
                
                if isBlack {
                    NSColor.black.set()
                    square.fill()
                }
            }

        }
    }
    
    func drawSprite(_ sprite: [UInt8], atRow: Int, andColumn: Int) {
        let bitRows = sprite.map(byteToPixels)
        
        for (r, bitRow) in bitRows.enumerated() {
            let originalBits = pixels[atRow + r][andColumn ..< (andColumn + bitRow.count)]
            
            let newBits = zip(bitRow, originalBits).map {(arg) -> Bool in let (b1, b2) = arg; return b1 != b2}
            
            pixels[atRow + r].replaceSubrange(andColumn ..< (andColumn + bitRow.count), with: newBits)
        }
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
