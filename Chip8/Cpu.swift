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
    var haltFlag = false
    
    let queue = DispatchQueue(label: "space.scown.chip8", qos: .utility)
    
    @IBOutlet var ram: Ram!
    @IBOutlet var buzzer: Buzzer!
    @IBOutlet var timer: Timer!
    @IBOutlet var stack: Stack!
    @IBOutlet var vram: VRam!
    @IBOutlet var kram: KRam!
    @IBOutlet var V: Registers!
    
    func reset() {
        I = 0
        PC = 512
        
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
        
        haltFlag = false
    }
    
    func execute() {
        if haltFlag {
            terminate()
            
            return
        }
        
        queue.async {
            print(self.PC)
            let (i1, i2, i3, i4) = self.getNextInstruction()
            
            var advance = true
            var execute = true
            
            if (i1 == 0) {
                if (i2 == 0 && i3 == 0xE && i4 == 0) {
                    self.CLS()
                }
                else if (i2 == 0 && i3 == 0xE && i4 == 0xE) {
                    self.RET()
                }
            }
            else if (i1 == 1) {
                self.JP(address: self.getAddress(i2, i3, i4))
                advance = false
            }
            else if (i1 == 2) {
                self.CALL(address: self.getAddress(i2, i3, i4))
                advance = false
            }
            else if (i1 == 3) {
                self.SE(register: i2, byte: self.getByte(i3, i4))
            }
            else if (i1 == 4) {
                self.SNE(register: i2, byte: self.getByte(i3, i4))
            }
            else if (i1 == 5 && i4 == 0) {
                self.SE(registerX: i2, registerY: i3)
            }
            else if (i1 == 6) {
                self.LD(register: i2, byte: self.getByte(i3, i4))
            }
            else if (i1 == 7) {
                self.ADD(register: i2, byte: self.getByte(i3, i4))
            }
            else if (i1 == 8) {
                if (i4 == 0) {
                    self.LD(registerX: i2, registerY: i3)
                }
                else if (i4 == 1) {
                    self.OR(registerX: i2, registerY: i3)
                }
                else if (i4 == 2) {
                    self.AND(registerX: i2, registerY: i3)
                }
                else if (i4 == 3) {
                    self.XOR(registerX: i2, registerY: i3)
                }
                else if (i4 == 4) {
                    self.ADD(registerX: i2, registerY: i3)
                }
                else if (i4 == 5) {
                    self.SUB(registerX: i2, registerY: i3)
                }
                else if (i4 == 6) {
                    self.SHR(registerX: i2, registerY: i3)
                }
                else if (i4 == 7) {
                    self.SUBN(registerX: i2, registerY: i3)
                }
                else if (i4 == 0xE) {
                    self.SHL(registerX: i2, registerY: i3)
                }
            }
            else if (i1 == 9 && i4 == 0) {
                self.SNE(registerX: i2, registerY: i3)
            }
            else if (i1 == 0xA) {
                self.LD(address: self.getAddress(i2, i3, i4))
            }
            else if (i1 == 0xB) {
                self.JPA(address: self.getAddress(i2, i3, i4))
                advance = false
            }
            else if (i1 == 0xC) {
                self.RND(register: i2, byte: self.getByte(i3, i4))
            }
            else if (i1 == 0xD) {
                self.DRW(registerX: i2, registerY: i3, length: i4)
            }
            else if (i1 == 0xE) {
                if (i3 == 9 && i4 == 0xE) {
                    self.SKP(register: i2)
                }
                else if (i3 == 0xA && i4 == 1) {
                    self.SKNP(register: i2)
                }
            }
            else if (i1 == 0xF) {
                if (i3 == 0 && i4 == 7) {
                    self.LD(register: i2)
                }
                else if (i3 == 0 && i4 == 0xA) {
                    self.LDK(register: i2)
                    execute = false
                }
                else if (i3 == 1 && i4 == 5) {
                    self.DT(register: i2)
                }
                else if (i3 == 1 && i4 == 8) {
                    self.ST(register: i2)
                }
                else if (i3 == 1 && i4 == 0xE) {
                    self.ADD(register: i2)
                }
                else if (i3 == 2 && i4 == 9) {
                    self.LDS(register: i2)
                }
                else if (i3 == 3 && i4 == 3) {
                    self.BCD(register: i2)
                }
                else if (i3 == 5 && i4 == 5) {
                    self.STO(register: i2)
                }
                else if (i3 == 6 && i4 == 5) {
                    self.LDR(register: i2)
                }
            }
            
            if advance {
                self.PC += 2
            }
            
            if execute {
                DispatchQueue.main.async {
                    self.execute()
                }
            }
        }
    }
    
    private func CLS() {
        print("CLS")
        
        DispatchQueue.main.sync {
            self.vram.clear()
        }
    }
    
    private func RET() {
        print("RET")
        
        self.PC = self.stack.pop()
    }
    
    private func JP(address: UInt16) {
        print("JP \(address)")
        
        self.PC = address
    }
    
    private func CALL(address: UInt16) {
        print("CALL \(address)")
        
        self.stack.push(self.PC)
        self.PC = address
    }
    
    private func SE(register: UInt8, byte: UInt8) {
        print("SE \(register), \(byte)")
        
        if (V[Int(register)] == byte) {
            print("true")
            
            self.PC += 2
        }
    }
    
    private func SNE(register: UInt8, byte: UInt8) {
        print("SNE \(register), \(byte)")
        
        if (V[Int(register)] != byte) {
            print("true")
            
            self.PC += 2
        }
    }
    
    private func SE(registerX: UInt8, registerY: UInt8) {
        print("SE R \(registerX), \(registerY)")
        
        if (V[Int(registerX)] == V[Int(registerY)]) {
            print("true")
            
            self.PC += 2
        }
    }
    
    private func LD(register: UInt8, byte: UInt8) {
        print("LD \(register), \(byte)")
        
        V[Int(register)] = byte
    }
    
    private func ADD(register: UInt8, byte: UInt8) {
        print("ADD \(register), \(byte)")
        
        (V[Int(register)], _) = V[Int(register)].addingReportingOverflow(byte)
    }
    
    private func LD(registerX: UInt8, registerY: UInt8) {
        print("LD R \(registerX), \(registerY)")
        
        V[Int(registerX)] = V[Int(registerY)]
    }
    
    private func OR(registerX: UInt8, registerY: UInt8) {
        print("OR \(registerX), \(registerY)")
        
        V[Int(registerX)] = V[Int(registerX)] | V[Int(registerY)]
    }
    
    private func AND(registerX: UInt8, registerY: UInt8) {
        print("AND \(registerX), \(registerY)")
        
        V[Int(registerX)] = V[Int(registerX)] & V[Int(registerY)]
    }
    
    private func XOR(registerX: UInt8, registerY: UInt8) {
        print("XOR \(registerX), \(registerY)")
        
        V[Int(registerX)] = V[Int(registerX)] ^ V[Int(registerY)]
    }
    
    private func ADD(registerX: UInt8, registerY: UInt8) {
        print("ADD R \(registerX), \(registerY)")
        
        let overflow: Bool
        
        (V[Int(registerX)], overflow) = V[Int(registerX)].addingReportingOverflow(V[Int(registerY)])
        
        if overflow {
            V[0xF] = 1
        }
    }
    
    private func SUB(registerX: UInt8, registerY: UInt8) {
        print("SUB \(registerX), \(registerY)")
        
        V[0xF] = V[Int(registerX)] > V[Int(registerY)] ? 1 : 0
        
        (V[Int(registerX)], _) = V[Int(registerX)].subtractingReportingOverflow(V[Int(registerY)])
    }
    
    private func SHR(registerX: UInt8, registerY: UInt8) {
        print("SHR \(registerX), \(registerY)")
        
        V[0xF] = (V[Int(registerX)] % 2) == 1 ? 1 : 0
        
        V[Int(registerX)] = V[Int(registerX)] >> 1
    }
    
    private func SUBN(registerX: UInt8, registerY: UInt8) {
        print("SUBN \(registerX), \(registerY)")
        
        V[0xF] = V[Int(registerY)] > V[Int(registerX)] ? 1 : 0
        
        (V[Int(registerX)], _) = V[Int(registerY)].subtractingReportingOverflow(V[Int(registerX)])
    }
    
    private func SHL(registerX: UInt8, registerY: UInt8) {
        print("SHL \(registerX), \(registerY)")
        
        V[0xF] = (V[Int(registerX)] & 0x80) == 0x80 ? 1 : 0
        
        V[Int(registerX)] = V[Int(registerX)] << 1
    }
    
    private func SNE(registerX: UInt8, registerY: UInt8) {
        print("SNE R \(registerX), \(registerY)")
        
        if (V[Int(registerX)] != V[Int(registerY)]) {
            self.PC += 2
        }
    }
    
    private func LD(address: UInt16) {
        print("LD I \(address)")
        
        self.I = address
    }
    
    private func JPA(address: UInt16) {
        print("JPA \(address)")
        
        self.PC = address + UInt16(V[0])
    }
    
    private func RND(register: UInt8, byte: UInt8) {
        print("RND \(register), \(byte)")
        
        V[Int(register)] = UInt8(arc4random_uniform(256)) & byte
    }
    
    private func DRW(registerX: UInt8, registerY: UInt8, length: UInt8) {
        print("DRW \(registerX), \(registerY), \(length)")
        
        let sprite = ram[Int(self.I) ..< (Int(self.I) + Int(length))]
        
        print(sprite)
        
        let row: Int = Int(self.V[Int(registerY)])
        let column: Int = Int(self.V[Int(registerX)])
        
        var collision = false
        
        DispatchQueue.main.sync {
            collision = self.vram.drawSprite(sprite, atRow: row, andColumn: column)
        }
        
        self.V[0xF] = collision ? 1 : 0
    }
    
    private func SKP(register: UInt8) {
        print("SKP \(register)")
        
        if kram.keys[Int(V[Int(register)])] {
            print("true")
            self.PC += 2
        }
    }
    
    private func SKNP(register: UInt8) {
        print("SKNP \(register) \(V[Int(register)])")
        
        if !kram.keys[Int(V[Int(register)])] {
            print("true")
            self.PC += 2
        }
    }
    
    private func LD(register: UInt8) {
        print("LD DELAY \(register)")
        
        V[Int(register)] = timer.delay
    }
    
    private func LDK(register: UInt8) {
        print("LDK \(register)")
        
        kram.keyHandler = { (_ k : UInt8) -> () in
            self.V[Int(register)] = k
            
            DispatchQueue.main.async {
                self.execute()
            }
        }
    }
    
    private func DT(register: UInt8) {
        print("DT \(register)")
        
        timer.startTimer(x: V[Int(register)])
    }
    
    private func ST(register: UInt8) {
        print("ST \(register)")
        
        buzzer.startTimer(x: V[Int(register)])
    }
    
    private func ADD(register: UInt8) {
        print("ADD \(register)")
        
        I = I + UInt16(V[Int(register)])
    }
    
    private func LDS(register: UInt8) {
        print("SPRITE \(register)")
        
        I = 5 * UInt16(V[Int(register)])
    }
    
    private func BCD(register: UInt8) {
        print("BCD \(register)")
        
        let value = V[Int(register)]
        let hundreds = value / 100
        let tens = (value % 100) / 10
        let ones = (value % 100) % 10
        
        ram[Int(I)] = hundreds
        ram[Int(I + 1)] = tens
        ram[Int(I + 2)] = ones
    }
    
    private func STO(register: UInt8) {
        print("STO \(register)")
        
        for i in 0 ... register {
            ram[Int(I + UInt16(i))] = V[Int(i)]
        }
    }
    
    private func LDR(register: UInt8) {
        print("LDR \(register)")
        
        for i in 0 ... register {
            V[Int(i)] = ram[Int(I + UInt16(i))]
        }
    }
    
    private func getNextInstruction() -> (UInt8, UInt8, UInt8, UInt8) {
        let bytes = ram[Int(PC) ..< Int(PC) + 2]
        
        return (bytes[0] >> 4, bytes[0] & 0xF, bytes[1] >> 4, bytes[1] & 0xF)
    }
    
    private func getAddress(_ i2: UInt8, _ i3: UInt8, _ i4: UInt8) -> UInt16 {
        return UInt16(i4) + 16 * UInt16(i3) + 256 * UInt16(i2)
    }
    
    private func getByte(_ hi: UInt8, _ lo: UInt8) -> UInt8 {
        return (hi << 4) + lo
    }
}
