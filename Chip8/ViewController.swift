//
//  ViewController.swift
//  Chip8
//
//  Created by Alexander Scown on 25/5/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var pixelView: PixelView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pv = pixelView {
            pv.pixels[0].replaceSubrange(5..<13, with: byteToPixels(240))
            pv.pixels[1].replaceSubrange(5..<13, with: byteToPixels(144))
            pv.pixels[2].replaceSubrange(5..<13, with: byteToPixels(144))
            pv.pixels[3].replaceSubrange(5..<13, with: byteToPixels(144))
            pv.pixels[4].replaceSubrange(5..<13, with: byteToPixels(240))
            
            pv.setNeedsDisplay(pv.bounds)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func byteToPixels(_ b: UInt8) -> [Bool] {
        let pixels: [Bool] = [
            b & 1 != 0,
            b & 2 != 0,
            b & 4 != 0,
            b & 8 != 0,
            b & 16 != 0,
            b & 32 != 0,
            b & 64 != 0,
            b & 128 != 0,
        ]
        
        return pixels
    }
    
}

