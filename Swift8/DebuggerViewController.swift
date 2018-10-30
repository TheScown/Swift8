//
//  DebuggerWindowController.swift
//  Chip8
//
//  Created by Alexander Scown on 23/8/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa

class DebuggerViewController: NSViewController {
    
    @objc weak dynamic var parentController: ViewController?
    
    @IBOutlet var ramTable: NSTableView!
        
    override func viewDidAppear() {
        super.viewDidAppear()
        
        parentController!.cpu.ramTable = ramTable
    }
    
    @IBAction func pause(sender: AnyObject) {
        parentController!.cpu.pauseFlag = true
    }
    
    @IBAction func unpause(sender: AnyObject) {
        parentController!.cpu.pauseFlag = false
        
        parentController!.cpu.execute()
    }
    
    @IBAction func step(sender: AnyObject) {
        parentController!.cpu.execute()
    }
        
}
