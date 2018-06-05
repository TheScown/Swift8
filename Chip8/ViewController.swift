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
            pv.drawSprite([240, 144, 144, 144, 240], atRow: 0, andColumn: 6)
            pv.drawSprite([240, 144, 144, 144, 240], atRow: 0, andColumn: 8)

            pv.setNeedsDisplay(pv.bounds)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}

