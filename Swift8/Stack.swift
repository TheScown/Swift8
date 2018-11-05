// Copyright 2018 Alex Scown

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
