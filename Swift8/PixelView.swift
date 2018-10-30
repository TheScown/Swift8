//
//  PixelView.swift
//  Chip8
//
//  Created by Alexander Scown on 31/5/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

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