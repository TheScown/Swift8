// Copyright 2018 Alex Scown

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet var pixelView: PixelView?
    @IBOutlet var chip8View: Chip8View?
    
    @IBOutlet var cpu: Cpu!
    @IBOutlet var ram: Ram!
    @IBOutlet var vram: VRam!
    @IBOutlet var stack: Stack!
    
    @objc dynamic var filePath: String = ""
    
    @objc dynamic var canRun: Bool = false
    @objc dynamic var canStop: Bool = false
    
    @objc dynamic var isRunning: Bool = false {
        willSet {
            self.willChangeValue(forKey: "canPause")
            self.willChangeValue(forKey: "canContinue")
        }
        didSet {
            self.didChangeValue(forKey: "canPause")
            self.didChangeValue(forKey: "canContinue")
        }
    }
    
    @objc dynamic var canPause: Bool {
        get {
            return isRunning && !cpu.pauseFlag
        }
    }
    
    @objc dynamic var canContinue: Bool {
        get {
            return isRunning && cpu.pauseFlag
        }
    }
    
    let queue = DispatchQueue(label: "space.scown.chip8", qos: .utility)
    
    private var pauseFlagToken: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseFlagToken = cpu.observe(\.pauseFlag) {[weak self] object, change in
            self!.willChangeValue(forKey: "canPause")
            self!.willChangeValue(forKey: "canContinue")
            self!.didChangeValue(forKey: "canPause")
            self!.didChangeValue(forKey: "canContinue")
        }
        
        chip8View!.delegate = self
        vram.pixelView = pixelView
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let windowController = segue.destinationController as? NSWindowController else { return }
        
        if let target = windowController.contentViewController as? DebuggerViewController {
            target.parentController = self
            
            self.cpu.ramTable = target.ramTable
        }
    }
    
    @IBAction func openFile(sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        dialog.title = "Open...";
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.allowsMultipleSelection = false;
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let result = dialog.url {
                filePath = result.path
                
                canRun = true
                canStop = false
                isRunning = false
            }
        }
    }
    
    @IBAction func run(sender: AnyObject) {
        isRunning = true
        canRun = false
        canStop = true
        
        chip8View!.becomeFirstResponder()
        
        self.cpu.reset()
        
        queue.async {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: self.filePath), options: .mappedIfSafe)
            
                let program = data[0 ..< min(4096 - 512, data.count)]
            
                self.ram[512 ..< 512 + program.count] = Array(program)
            
                DispatchQueue.main.async {
                    self.execute()
                }
            } catch {}
        }
    }
    
    @IBAction func halt(sender: AnyObject) {
        cpu.halt()
        self.chip8View!.resignFirstResponder()
        
        isRunning = false
        canRun = true
        canStop = false
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func execute() {
        cpu.execute()
    }
    
    private func resetEmulator() {
        cpu.reset()
    }
    
}

