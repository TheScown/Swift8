//
//  ViewController.swift
//  Chip8
//
//  Created by Alexander Scown on 25/5/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet var pixelView: PixelView?
    @IBOutlet var chip8View: Chip8View?
    
    @IBOutlet var cpu: Cpu!
    @IBOutlet var ram: Ram!
    @IBOutlet var vram: VRam!
    
    @objc dynamic var canRun: Bool = false
    @objc dynamic var canStop: Bool = false
    @objc dynamic var isRunning: Bool = false
    @objc dynamic var filePath: String = ""
    
    let queue = DispatchQueue(label: "space.scown.chip8", qos: .utility)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chip8View!.delegate = self
        vram.pixelView = pixelView
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
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedIfSafe)
            
            let program = data[0 ..< min(4096 - 512, data.count)]
            
            self.ram[512 ..< 512 + program.count] = Array(program)
            
            execute()
        } catch {}
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

