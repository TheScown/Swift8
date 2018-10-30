//
//  VRam.swift
//  Chip8
//
//  Created by Alexander Scown on 20/6/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

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
