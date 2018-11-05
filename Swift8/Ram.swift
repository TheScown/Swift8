// Copyright 2018 Alex Scown

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Cocoa

class Ram: NSObject {
    
    let RAM_SIZE = 4096

    @objc dynamic var ram = [RamCell]()
    
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
        ] + [UInt8](repeating: 0, count: RAM_SIZE - 80)).enumerated().map { arg in
            let (address, byte) = arg
            return RamCell(address, byte, Nop())
        }
    }
    
    func getInstructionAt(index: Int) -> Instruction {
        return ram[index].instruction
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
                var instruction: Instruction = Nop()
                var previousInstruction: Instruction = Nop()
                
                if index != RAM_SIZE - 1 {
                    instruction = getInstruction(hi: newElm, lo: ram[index + 1].byte)
                }
                
                if index != 0 {
                    let previousCell = ram[index - 1]
                    previousInstruction = getInstruction(hi: previousCell.byte, lo: newElm)
                    ram[index - 1] = previousCell.withInstruction(previousInstruction)
                }
                
                ram[index] = RamCell(index, newElm, instruction)
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
            var newRam = [RamCell]()
            
            for (i, byte) in newElm.enumerated() {
                var instruction: Instruction = Nop()
                var previousInstruction: Instruction = Nop()
                
                if i == index.count - 1 && index.lowerBound + i != RAM_SIZE - 1 {
                    DispatchQueue.main.sync {
                        instruction = getInstruction(hi: byte, lo: ram[index.lowerBound + i + 1].byte)
                    }
                }
                
                if (i == 0 && index.lowerBound != 0) {
                    DispatchQueue.main.sync {
                        let previousCell = ram[index.lowerBound + i - 1]
                        previousInstruction = getInstruction(hi: previousCell.byte, lo: byte)
                        
                        ram[index.lowerBound + i - 1] = previousCell.withInstruction(previousInstruction)
                    }
                }
                else {
                    let previousCell = newRam[i - 1]
                    previousInstruction = getInstruction(hi: newRam[i - 1].byte, lo: byte)
                    
                    newRam[i - 1] = previousCell.withInstruction(previousInstruction)
                }
                
                newRam.append(RamCell(i + index.lowerBound, byte, instruction))
            }
            
            DispatchQueue.main.sync {
                ram.replaceSubrange(index, with: newRam)
            }
        }
    }
}

class RamCell: NSObject {
    @objc dynamic let address: Int
    @objc dynamic let byte: UInt8
    @objc dynamic let instruction: Instruction
    
    init(_ address: Int, _ byte: UInt8, _ instruction: Instruction) {
        self.address = address
        self.byte = byte
        self.instruction = instruction
        super.init()
    }
    
    func withInstruction(_ instruction: Instruction) -> RamCell {
        return RamCell(address, byte, instruction)
    }
}
