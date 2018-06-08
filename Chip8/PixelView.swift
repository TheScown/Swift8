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
            let row: Int = (atRow + r) % 32
            
            for (c, b) in bitRow.enumerated() {
                let col: Int = (andColumn + c) % 64
                pixels[row][col] = pixels[row][col] != b
            }
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
