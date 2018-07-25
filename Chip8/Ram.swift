//
//  Ram.swift
//  Chip8
//
//  Created by Alexander Scown on 20/6/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa

class Ram: NSObject {

    @objc dynamic var ram = [ByteCell]()
    
    func reset() {
        ram = ([
            0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
            0x20, 0x60, 0x20, 0x20, 0x70, // 1
            0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
            0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
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
        ] + [UInt8](repeating: 0, count: 4096 - 80)).enumerated().map { arg in
            let (address, byte) = arg
            return ByteCell(address, byte)
        }
    }
    
    subscript(index: Int) -> UInt8 {
        get {
            var result: UInt8 = 0
            
            DispatchQueue.main.sync {
                result = ram[index].byte
            }
            
            return result
        }
        set(newElm) {
            DispatchQueue.main.sync {
                ram[index] = ByteCell(index, newElm)
            }
        }
    }
    
    subscript(index: Range<Int>) -> [UInt8] {
        get {
            var result = [UInt8]()
            
            DispatchQueue.main.sync {
                result = Array(ram[index]).map { byteCell in byteCell.byte }
            }
            
            return result
        }
        set(newElm) {
            let newCells = newElm.enumerated().map { arg -> ByteCell in
                let (i, byte) = arg
                
                return ByteCell(i + index.lowerBound, byte)
            }
            
            DispatchQueue.main.sync {
                ram.replaceSubrange(index, with: newCells)
            }
        }
    }
    
}
