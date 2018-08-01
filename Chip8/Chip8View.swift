//
//  Chip8View.swift
//  Chip8
//
//  Created by Alexander Scown on 10/6/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa

class Chip8View: NSView {
    
    weak var delegate: ViewController!
    
    @IBOutlet var kram: KRam!
    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func keyDown(with event: NSEvent) {
        kram.keyDown(with: event)
    }
    
    override func keyUp(with event: NSEvent) {
        kram.keyUp(with: event)
    }
    
    @IBAction func openDocument(_ sender: Any?) {
        delegate.openFile(sender: self)
    }
    
    @IBAction func runChip8(_ sender: AnyObject) {
        delegate.run(sender: sender)
    }
    
    @IBAction func stopChip8(_ sender: AnyObject) {
        delegate.halt(sender: sender)
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(Chip8View.runChip8(_:)) {
            return delegate.canRun
        }
        else if menuItem.action == #selector(Chip8View.stopChip8(_:)) {
            return delegate.canStop
        }
        else if menuItem.action == #selector(Chip8View.openDocument(_:)) {
            return !(delegate.isRunning)
        }
        
        return true;
    }
    
}
