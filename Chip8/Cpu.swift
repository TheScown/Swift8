//
//  Cpu.swift
//  Chip8
//
//  Created by Alexander Scown on 20/6/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa

class Cpu: NSObject {
    var I: UInt16 = 0
    var PC: UInt16 = 0
    @objc dynamic var pcIndex: IndexSet = IndexSet()
    var haltFlag = false
    @objc dynamic var pauseFlag = false
    
    let queue = DispatchQueue(label: "space.scown.chip8", qos: .utility)
    
    @IBOutlet var ram: Ram!
    @IBOutlet var buzzer: Buzzer!
    @IBOutlet var timer: Timer!
    @IBOutlet var stack: Stack!
    @IBOutlet var vram: VRam!
    @IBOutlet var kram: KRam!
    @IBOutlet var V: Registers!
    @IBOutlet var ramTable: NSTableView!
    
    func reset() {
        I = 0
        setPC(512)
        haltFlag = false
        pauseFlag = false
        
        V.reset()
        ram.reset()
        buzzer.reset()
        timer.reset()
        stack.reset()
        vram.clear()
    }
    
    func halt() {
        if kram.keyHandler != nil {
            terminate()
        }
        else {
            haltFlag = true
        }
    }
    
    func terminate() {
        buzzer.terminate()
    }
    
    func execute() {
        if haltFlag {
            terminate()
            
            return
        }
        
        queue.async {
            let instruction = self.getNextInstruction()
            
            instruction.execute(onCpu: self)
            
            if instruction.advance {
                DispatchQueue.main.sync {
                    self.setPC(self.PC + 2)
                }
            }
            
            let nextInstruction = self.getNextInstruction()
            
            DispatchQueue.main.async {
                if nextInstruction.breakpoint {
                    self.pauseFlag = true
                }
                
                if !(self.pauseFlag || instruction.pause) {
                    self.execute()
                }
            }
        }
    }
    
    func CLS() {
        DispatchQueue.main.sync {
            self.vram.clear()
        }
    }
    
    func RET() {
        let _ = DispatchQueue.main.sync {
            pcIndex.remove(Int(PC))
        }
        
        PC = stack.pop()
        
        DispatchQueue.main.sync {
            pcIndex.insert(Int(PC))
            ramTable.scrollRowToVisible(Int(PC))
        }
    }
    
    func JP(address: UInt16) {
        DispatchQueue.main.sync {
            setPC(address)
        }
    }
    
    func CALL(address: UInt16) {
        self.stack.push(self.PC)
        
        DispatchQueue.main.sync {
            setPC(address)
        }
    }
    
    func SE(register: UInt8, byte: UInt8) {
        if (V[Int(register)] == byte) {
            DispatchQueue.main.sync {
                setPC(PC + 2)
            }
        }
    }
    
    func SNE(register: UInt8, byte: UInt8) {
        if (V[Int(register)] != byte) {
            DispatchQueue.main.sync {
                setPC(PC + 2)
            }
        }
    }
    
    func SE(registerX: UInt8, registerY: UInt8) {
        if (V[Int(registerX)] == V[Int(registerY)]) {
            DispatchQueue.main.sync {
                setPC(PC + 2)
            }
        }
    }
    
    func LD(register: UInt8, byte: UInt8) {
        V[Int(register)] = byte
    }
    
    func ADD(register: UInt8, byte: UInt8) {
        (V[Int(register)], _) = V[Int(register)].addingReportingOverflow(byte)
    }
    
    func LD(registerX: UInt8, registerY: UInt8) {
        V[Int(registerX)] = V[Int(registerY)]
    }
    
    func OR(registerX: UInt8, registerY: UInt8) {
        V[Int(registerX)] = V[Int(registerX)] | V[Int(registerY)]
    }
    
    func AND(registerX: UInt8, registerY: UInt8) {
        V[Int(registerX)] = V[Int(registerX)] & V[Int(registerY)]
    }
    
    func XOR(registerX: UInt8, registerY: UInt8) {
        V[Int(registerX)] = V[Int(registerX)] ^ V[Int(registerY)]
    }
    
    func ADD(registerX: UInt8, registerY: UInt8) {
        let overflow: Bool
        
        (V[Int(registerX)], overflow) = V[Int(registerX)].addingReportingOverflow(V[Int(registerY)])
        
        if overflow {
            V[0xF] = 1
        }
    }
    
    func SUB(registerX: UInt8, registerY: UInt8) {
        V[0xF] = V[Int(registerX)] > V[Int(registerY)] ? 1 : 0
        
        (V[Int(registerX)], _) = V[Int(registerX)].subtractingReportingOverflow(V[Int(registerY)])
    }
    
    func SHR(registerX: UInt8, registerY: UInt8) {
        V[0xF] = (V[Int(registerX)] % 2) == 1 ? 1 : 0
        
        V[Int(registerX)] = V[Int(registerX)] >> 1
    }
    
    func SUBN(registerX: UInt8, registerY: UInt8) {
        V[0xF] = V[Int(registerY)] > V[Int(registerX)] ? 1 : 0
        
        (V[Int(registerX)], _) = V[Int(registerY)].subtractingReportingOverflow(V[Int(registerX)])
    }
    
    func SHL(registerX: UInt8, registerY: UInt8) {
        V[0xF] = (V[Int(registerX)] & 0x80) == 0x80 ? 1 : 0
        
        V[Int(registerX)] = V[Int(registerX)] << 1
    }
    
    func SNE(registerX: UInt8, registerY: UInt8) {
        if (V[Int(registerX)] != V[Int(registerY)]) {
            DispatchQueue.main.sync {
                setPC(PC + 2)
            }
        }
    }
    
    func LD(address: UInt16) {
        self.I = address
    }
    
    func JPA(address: UInt16) {
        DispatchQueue.main.sync {
            setPC(address + UInt16(V[0]))
        }
    }
    
    func RND(register: UInt8, byte: UInt8) {
        V[Int(register)] = UInt8(arc4random_uniform(256)) & byte
    }
    
    func DRW(registerX: UInt8, registerY: UInt8, length: UInt8) {
        let sprite = ram[Int(self.I) ..< (Int(self.I) + Int(length))]
                
        let row: Int = Int(self.V[Int(registerY)])
        let column: Int = Int(self.V[Int(registerX)])
        
        var collision = false
        
        DispatchQueue.main.sync {
            collision = self.vram.drawSprite(sprite, atRow: row, andColumn: column)
        }
        
        self.V[0xF] = collision ? 1 : 0
    }
    
    func SKP(register: UInt8) {
        if kram.keys[Int(V[Int(register)])] {
            DispatchQueue.main.sync {
                setPC(PC + 2)
            }
        }
    }
    
    func SKNP(register: UInt8) {
        if !kram.keys[Int(V[Int(register)])] {
            DispatchQueue.main.sync {
                setPC(PC + 2)
            }
        }
    }
    
    func LD(register: UInt8) {
        V[Int(register)] = timer.delay
    }
    
    func LDK(register: UInt8) {
        kram.keyHandler = { (_ k : UInt8) -> () in
            self.V[Int(register)] = k
            
            DispatchQueue.main.async {
                self.execute()
            }
        }
    }
    
    func DT(register: UInt8) {
        timer.startTimer(x: V[Int(register)])
    }
    
    func ST(register: UInt8) {
        buzzer.startTimer(x: V[Int(register)])
    }
    
    func ADD(register: UInt8) {
        I = I + UInt16(V[Int(register)])
    }
    
    func LDS(register: UInt8) {
        I = 5 * UInt16(V[Int(register)])
    }
    
    func BCD(register: UInt8) {
        let value = V[Int(register)]
        let hundreds = value / 100
        let tens = (value % 100) / 10
        let ones = (value % 100) % 10
        
        ram[Int(I)] = hundreds
        ram[Int(I + 1)] = tens
        ram[Int(I + 2)] = ones
    }
    
    func STO(register: UInt8) {
        for i in 0 ... register {
            ram[Int(I + UInt16(i))] = V[Int(i)]
        }
    }
    
    func LDR(register: UInt8) {
        for i in 0 ... register {
            V[Int(i)] = ram[Int(I + UInt16(i))]
        }
    }
    
    private func getNextInstruction() -> Instruction {
        return ram.getInstructionAt(index: Int(PC))
    }
    
    private func setPC(_ newValue: UInt16) {
        pcIndex.remove(Int(PC))
        PC = newValue
        pcIndex.insert(Int(PC))
        ramTable.scrollRowToVisible(Int(PC))
    }
}
