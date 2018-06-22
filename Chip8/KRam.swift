//
//  KRam.swift
//  Chip8
//
//  Created by Alexander Scown on 21/6/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa

class KRam: NSObject {

    let queue = DispatchQueue(label: "space.scown.chip8", qos: .utility)
    
    var keyHandler: ((UInt8) -> ())?
    
    var keys = Array(repeating: false, count: 16)
    
    let keyValues: Dictionary<String, UInt8> = [
        "1": 1,
        "2": 2,
        "3": 3,
        "4": 0xC,
        "q": 4,
        "w": 5,
        "e": 6,
        "r": 0xD,
        "a": 7,
        "s": 8,
        "d": 9,
        "f": 0xE,
        "z": 0xA,
        "x": 0,
        "c": 0xB,
        "v": 0xF
    ]
    
    func keyDown(with event: NSEvent) {
        if let string = event.charactersIgnoringModifiers {
            queue.async {
                print("keydown \(string)")
                self.setKeys(string, true)
            }
        }
    }
    
    func keyUp(with event: NSEvent) {
        if let string = event.charactersIgnoringModifiers {
            queue.async {
                print("keyup \(string)")
                self.setKeys(string, false)
            }
        }
    }
    
    private func setKeys(_ string: String, _ flag: Bool) {
        for key in string {
            if let keyByte = keyValues[String(key)] {
                keys[Int(keyByte)] = flag
                
                if flag {
                    if let keyHandler = self.keyHandler {
                        keyHandler(keyByte)
                        
                        self.keyHandler = nil
                    }
                }
            }
        }
    }
    
}
