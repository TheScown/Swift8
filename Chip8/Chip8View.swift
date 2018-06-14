//
//  Chip8View.swift
//  Chip8
//
//  Created by Alexander Scown on 10/6/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa

class Chip8View: NSView {
    
    weak var delegate: ViewController?
    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func keyDown(with event: NSEvent) {
        delegate!.keyDown(with: event)
    }
    
    override func keyUp(with event: NSEvent) {
        delegate!.keyUp(with: event)
    }
    
}
