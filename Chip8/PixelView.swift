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
        
        for row in Int(dirtyRect.minY) / RES ..< Int(ceil(Double(Int(dirtyRect.maxY) / RES))) {
            for col in Int(dirtyRect.minX) / RES ..< Int(ceil(Double(Int(dirtyRect.maxX) / RES))) {
                let isBlack = pixels[row][col]
                let square = NSRect.init(x: col * RES, y: row * RES, width: RES, height: RES)
                
                if isBlack {
                    NSColor.black.set()
                }
                else {
                    NSColor.white.set()
                }
                
                square.fill()
            }

        }
    }
    
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
                    
                    self.setNeedsDisplay(NSRect(x: col * RES, y: row * RES, width: RES, height: RES))
                }
            }
        }
        
        return returnValue
    }
    
    func clear() {
        pixels = Array(repeating: Array(repeating: false, count: 64), count: 32)
        
        self.needsDisplay = true
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
