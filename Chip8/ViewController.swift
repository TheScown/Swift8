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
    @IBOutlet var textField: NSTextField?
    @IBOutlet var open: NSButton?
    @IBOutlet var run: NSButton?
    
    var player = AVAudioPlayer()
    
    var ram: Array<UInt8> = [
        0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 3
        0x90, 0x90, 0xF0, 0x10, 0x10, // 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
        0xF0, 0x10, 0x20, 0x40, 0x40, // 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, // A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
        0xF0, 0x80, 0x80, 0x80, 0xF0, // C
        0xE0, 0x90, 0x90, 0x90, 0xE0, // D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
        0xF0, 0x80, 0xF0, 0x80, 0x80, // F
    ] + [UInt8](repeating: 0, count: 4096 - 80)
    
    var V = [UInt8](repeating: 0, count: 16)
    var I: UInt16 = 0
    var delay: UInt8 = 0
    var sound: UInt8 = 0
    var PC: UInt16 = 0
    var SP: UInt8 = 0
    var stack = [UInt16](repeating: 0, count: 16)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path: String? = Bundle.main.path(forResource: "440", ofType: "wav")
        
        do {
            try player = AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: path!))
            player.numberOfLoops = -1
        } catch {}
    }
    
    @IBAction func openFile(sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Open...";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let result = dialog.url {
                textField!.stringValue = result.path
                
                do {
                    let data = try Data(contentsOf: result, options: .mappedIfSafe)
                    
                    let program = data[0 ..< min(4096 - 512, data.count)]
                    
                    ram.replaceSubrange(512 ..< 512 + program.count, with: program)
                    
                    run!.isEnabled = true
                } catch {}
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func accessRam(address: Int, length: Int) -> [UInt8] {
        return Array(self.ram[address ..< address + length])
    }
    
}

