//
//  Registers.swift
//  Chip8
//
//  Created by Alexander Scown on 20/7/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Foundation

class Registers: NSObject {
    @objc dynamic var registers = [ByteCell]()
    
    func reset() {
        registers = (0 ..< 16).map { (a) -> ByteCell in ByteCell(a, 0)}
    }
    
    subscript(index: Int) -> UInt8 {
        get {
            var result: UInt8 = 0
            
            DispatchQueue.main.sync {
                result = registers[index].byte
            }
            
            return result
        }
        set(newElm) {
            DispatchQueue.main.sync {
                registers[index] = ByteCell(index, newElm)
            }
        }
    }
}

class RegisterFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        if let index = obj {
            return "V\(index)"
        }
        
        return "V"
    }
}

