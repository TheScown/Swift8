//
//  Stack.swift
//  Chip8
//
//  Created by Alexander Scown on 20/6/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa

class Stack: NSObject {

    private var stack = [UInt16]()
    private var SP = -1
    
    func reset() {
        stack = Array(repeating: 0, count: 16)
        SP = -1
    }
    
    func push(_ x: UInt16) {
        SP += 1
        stack[Int(SP)] = x
    }
    
    func pop() -> UInt16 {
        let result = stack[Int(SP)]
        
        SP -= 1
        
        return result
    }
    
}
