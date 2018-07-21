//
//  Stack.swift
//  Chip8
//
//  Created by Alexander Scown on 20/6/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa

class Stack: NSObject {

    @objc dynamic var stack = [AddressCell]()
    var SP = -1
    @objc dynamic var indexSet: IndexSet = IndexSet()
    
    func reset() {
        stack = (0 ..< 16).map {(index) in AddressCell(index, 0)}
        SP = -1
        indexSet = IndexSet.init(integer: -1)
    }
    
    func push(_ x: UInt16) {
        DispatchQueue.main.sync {
            indexSet.remove(SP)
            SP += 1
            indexSet.insert(SP)
            stack[SP] = AddressCell(SP, x)
        }
    }
    
    func pop() -> UInt16 {
        var finalResult: UInt16 = 0
        
        DispatchQueue.main.sync {
            let result = stack[SP]
            stack[SP] = AddressCell(SP, 0)
            indexSet.remove(SP)
            
            SP -= 1
            
            indexSet.insert(SP)
            
            finalResult = result.value
        }
        
        return finalResult
    }
    
}

class AddressCell: NSObject {
    @objc dynamic let address: Int
    @objc dynamic let value: UInt16
    
    init(_ address: Int, _ value: UInt16) {
        self.address = address
        self.value = value
    }
}
