// Copyright 2018 Alex Scown

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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

