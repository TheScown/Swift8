// Copyright 2018 Alex Scown

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
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
