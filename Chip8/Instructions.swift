//
//  Instructions.swift
//  Chip8
//
//  Created by Alexander Scown on 29/7/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Foundation

@objc protocol Instruction {
    var mnemonic: String { get }
    var advance: Bool { get }
    var pause: Bool { get }
    func execute(onCpu: Cpu)
}

func getInstruction(hi: UInt8, lo: UInt8) -> Instruction {
    let (i1, i2, i3, i4) = (hi >> 4, hi & 0xF, lo >> 4, lo & 0xF)
    
    if (i1 == 0) {
        if (i2 == 0 && i3 == 0xE && i4 == 0) {
            return Cls()
        }
        else if (i2 == 0 && i3 == 0xE && i4 == 0xE) {
            return Ret()
        }
    }
    else if (i1 == 1) {
        return Jp(getAddress(i2, i3, i4))
    }
    else if (i1 == 2) {
        return Call(getAddress(i2, i3, i4))
    }
    else if (i1 == 3) {
        return Se(i2, getByte(i3, i4))
    }
    else if (i1 == 4) {
        return Sne(i2, getByte(i3, i4))
    }
    else if (i1 == 5 && i4 == 0) {
        return Ser(i2, i3)
    }
    else if (i1 == 6) {
        return Ld(i2, getByte(i3, i4))
    }
    else if (i1 == 7) {
        return Add(i2, getByte(i3, i4))
    }
    else if (i1 == 8) {
        if (i4 == 0) {
            return Ldr(i2, i3)
        }
        else if (i4 == 1) {
            return Or(i2, i3)
        }
        else if (i4 == 2) {
            return And(i2, i3)
        }
        else if (i4 == 3) {
            return Xor(i2, i3)
        }
        else if (i4 == 4) {
            return Addr(i2, i3)
        }
        else if (i4 == 5) {
            return Sub(i2, i3)
        }
        else if (i4 == 6) {
            return Shr(i2, i3)
        }
        else if (i4 == 7) {
            return Subn(i2, i3)
        }
        else if (i4 == 0xE) {
            return Shl(i2, i3)
        }
    }
    else if (i1 == 9 && i4 == 0) {
        return Sner(i2, i3)
    }
    else if (i1 == 0xA) {
        return Ldi(getAddress(i2, i3, i4))
    }
    else if (i1 == 0xB) {
        return Jpa(getAddress(i2, i3, i4))
    }
    else if (i1 == 0xC) {
        return Rnd(i2, getByte(i3, i4))
    }
    else if (i1 == 0xD) {
        return Drw(i2, i3, i4)
    }
    else if (i1 == 0xE) {
        if (i3 == 9 && i4 == 0xE) {
            return Skp(i2)
        }
        else if (i3 == 0xA && i4 == 1) {
            return Sknp(i2)
        }
    }
    else if (i1 == 0xF) {
        if (i3 == 0 && i4 == 7) {
            return Lddt(i2)
        }
        else if (i3 == 0 && i4 == 0xA) {
            return Ldk(i2)
        }
        else if (i3 == 1 && i4 == 5) {
            return Ldrdt(i2)
        }
        else if (i3 == 1 && i4 == 8) {
            return St(i2)
        }
        else if (i3 == 1 && i4 == 0xE) {
            return Addi(i2)
        }
        else if (i3 == 2 && i4 == 9) {
            return Ldf(i2)
        }
        else if (i3 == 3 && i4 == 3) {
            return Ldb(i2)
        }
        else if (i3 == 5 && i4 == 5) {
            return Ldir(i2)
        }
        else if (i3 == 6 && i4 == 5) {
            return Ldri(i2)
        }
    }
    
    return Nop()
}

private func getAddress(_ i2: UInt8, _ i3: UInt8, _ i4: UInt8) -> UInt16 {
    return UInt16(i4) + 16 * UInt16(i3) + 256 * UInt16(i2)
}

private func getByte(_ hi: UInt8, _ lo: UInt8) -> UInt8 {
    return (hi << 4) + lo
}

@objc class Nop: NSObject, Instruction {
    let mnemonic = ""
    let advance = false
    let pause = true
    
    func execute(onCpu: Cpu) {}
}

@objc class Cls: NSObject, Instruction {
    let mnemonic = "CLS"
    let advance = true
    let pause = false
    
    func execute(onCpu: Cpu) {
        onCpu.CLS()
    }
}

@objc class Ret: NSObject, Instruction {
    let mnemonic = "RET"
    let advance = true
    let pause = false
    
    func execute(onCpu: Cpu) {
        onCpu.RET()
    }
}

@objc class Jp: NSObject, Instruction {
    let address: UInt16
    let advance = false
    let pause = false
    
    var mnemonic: String {
        get {
            return "JP \(address)"
        }
    }
    
    init(_ address: UInt16) {
        self.address = address
    }
    
    func execute(onCpu: Cpu) {
        onCpu.JP(address: address)
    }
}

@objc class Call: NSObject, Instruction {
    let address: UInt16
    let advance = false
    let pause = false
    
    var mnemonic: String {
        get {
            return "CALL \(address)"
        }
    }
    
    init(_ address: UInt16) {
        self.address = address
    }
    
    func execute(onCpu: Cpu) {
        onCpu.CALL(address: address)
    }
}

@objc class Se: NSObject, Instruction {
    let register: UInt8
    let byte: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "SE V\(register), \(byte)"
        }
    }
    
    init(_ register: UInt8, _ byte: UInt8) {
        self.register = register
        self.byte = byte
    }
    
    func execute(onCpu: Cpu) {
        onCpu.SE(register: register, byte: byte)
    }
}

@objc class Sne: NSObject, Instruction {
    let register: UInt8
    let byte: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "SNE V\(register), \(byte)"
        }
    }
    
    init(_ register: UInt8, _ byte: UInt8) {
        self.register = register
        self.byte = byte
    }
    
    func execute(onCpu: Cpu) {
        onCpu.SNE(register: register, byte: byte)
    }
}

@objc class Ser: NSObject, Instruction {
    let registerX: UInt8
    let registerY: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "SE V\(registerX), V\(registerY)"
        }
    }
    
    init(_ registerX: UInt8, _ registerY: UInt8) {
        self.registerX = registerX
        self.registerY = registerY
    }
    
    func execute(onCpu: Cpu) {
        onCpu.SE(registerX: registerX, registerY: registerY)
    }
}

@objc class Ld: NSObject, Instruction {
    let register: UInt8
    let byte: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "LD V\(register), \(byte)"
        }
    }
    
    init(_ register: UInt8, _ byte: UInt8) {
        self.register = register
        self.byte = byte
    }
    
    func execute(onCpu: Cpu) {
        onCpu.LD(register: register, byte: byte)
    }
}

@objc class Add: NSObject, Instruction {
    let register: UInt8
    let byte: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "ADD V\(register), \(byte)"
        }
    }
    
    init(_ register: UInt8, _ byte: UInt8) {
        self.register = register
        self.byte = byte
    }
    
    func execute(onCpu: Cpu) {
        onCpu.ADD(register: register, byte: byte)
    }
}

@objc class Ldr: NSObject, Instruction {
    let registerX: UInt8
    let registerY: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "LD V\(registerX), V\(registerY)"
        }
    }
    
    init(_ registerX: UInt8, _ registerY: UInt8) {
        self.registerX = registerX
        self.registerY = registerY
    }
    
    func execute(onCpu: Cpu) {
        onCpu.LD(registerX: registerX, registerY: registerY)
    }
}

@objc class Or: NSObject, Instruction {
    let registerX: UInt8
    let registerY: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "OR V\(registerX), V\(registerY)"
        }
    }
    
    init(_ registerX: UInt8, _ registerY: UInt8) {
        self.registerX = registerX
        self.registerY = registerY
    }
    
    func execute(onCpu: Cpu) {
        onCpu.OR(registerX: registerX, registerY: registerY)
    }
}

@objc class And: NSObject, Instruction {
    let registerX: UInt8
    let registerY: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "AND V\(registerX), V\(registerY)"
        }
    }
    
    init(_ registerX: UInt8, _ registerY: UInt8) {
        self.registerX = registerX
        self.registerY = registerY
    }
    
    func execute(onCpu: Cpu) {
        onCpu.AND(registerX: registerX, registerY: registerY)
    }
}

@objc class Xor: NSObject, Instruction {
    let registerX: UInt8
    let registerY: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "XOR V\(registerX), V\(registerY)"
        }
    }
    
    init(_ registerX: UInt8, _ registerY: UInt8) {
        self.registerX = registerX
        self.registerY = registerY
    }
    
    func execute(onCpu: Cpu) {
        onCpu.XOR(registerX: registerX, registerY: registerY)
    }
}

@objc class Addr: NSObject, Instruction {
    let registerX: UInt8
    let registerY: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "ADD V\(registerX), V\(registerY)"
        }
    }
    
    init(_ registerX: UInt8, _ registerY: UInt8) {
        self.registerX = registerX
        self.registerY = registerY
    }
    
    func execute(onCpu: Cpu) {
        onCpu.ADD(registerX: registerX, registerY: registerY)
    }
}

@objc class Sub: NSObject, Instruction {
    let registerX: UInt8
    let registerY: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "SUB V\(registerX), V\(registerY)"
        }
    }
    
    init(_ registerX: UInt8, _ registerY: UInt8) {
        self.registerX = registerX
        self.registerY = registerY
    }
    
    func execute(onCpu: Cpu) {
        onCpu.SUB(registerX: registerX, registerY: registerY)
    }
}

@objc class Shr: NSObject, Instruction {
    let registerX: UInt8
    let registerY: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "SHR V\(registerX), V\(registerY)"
        }
    }
    
    init(_ registerX: UInt8, _ registerY: UInt8) {
        self.registerX = registerX
        self.registerY = registerY
    }
    
    func execute(onCpu: Cpu) {
        onCpu.SHR(registerX: registerX, registerY: registerY)
    }
}

@objc class Subn: NSObject, Instruction {
    let registerX: UInt8
    let registerY: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "SUBN V\(registerX), V\(registerY)"
        }
    }
    
    init(_ registerX: UInt8, _ registerY: UInt8) {
        self.registerX = registerX
        self.registerY = registerY
    }
    
    func execute(onCpu: Cpu) {
        onCpu.SUBN(registerX: registerX, registerY: registerY)
    }
}

@objc class Shl: NSObject, Instruction {
    let registerX: UInt8
    let registerY: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "SHL V\(registerX), V\(registerY)"
        }
    }
    
    init(_ registerX: UInt8, _ registerY: UInt8) {
        self.registerX = registerX
        self.registerY = registerY
    }
    
    func execute(onCpu: Cpu) {
        onCpu.SHL(registerX: registerX, registerY: registerY)
    }
}

@objc class Sner: NSObject, Instruction {
    let registerX: UInt8
    let registerY: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "SNE V\(registerX), V\(registerY)"
        }
    }
    
    init(_ registerX: UInt8, _ registerY: UInt8) {
        self.registerX = registerX
        self.registerY = registerY
    }
    
    func execute(onCpu: Cpu) {
        onCpu.SNE(registerX: registerX, registerY: registerY)
    }
}

@objc class Ldi: NSObject, Instruction {
    let address: UInt16
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "LD I, \(address)"
        }
    }
    
    init(_ address: UInt16) {
        self.address = address
    }
    
    func execute(onCpu: Cpu) {
        onCpu.LD(address: address)
    }
}

@objc class Jpa: NSObject, Instruction {
    let address: UInt16
    let advance = false
    let pause = false
    
    var mnemonic: String {
        get {
            return "JP V0, \(address)"
        }
    }
    
    init(_ address: UInt16) {
        self.address = address
    }
    
    func execute(onCpu: Cpu) {
        onCpu.JPA(address: address)
    }
}

@objc class Rnd: NSObject, Instruction {
    let register: UInt8
    let byte: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "RND V\(register), \(byte)"
        }
    }
    
    init(_ register: UInt8, _ byte: UInt8) {
        self.register = register
        self.byte = byte
    }
    
    func execute(onCpu: Cpu) {
        onCpu.RND(register: register, byte: byte)
    }
}

@objc class Drw: NSObject, Instruction {
    let registerX: UInt8
    let registerY: UInt8
    let length: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "DRW V\(registerX), V\(registerY), \(length)"
        }
    }
    
    init(_ registerX: UInt8, _ registerY: UInt8, _ length: UInt8) {
        self.registerX = registerX
        self.registerY = registerY
        self.length = length
    }
    
    func execute(onCpu: Cpu) {
        onCpu.DRW(registerX: registerX, registerY: registerY, length: length)
    }
}

@objc class Skp: NSObject, Instruction {
    let register: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "SKP V\(register)"
        }
    }
    
    init(_ register: UInt8) {
        self.register = register
    }
    
    func execute(onCpu: Cpu) {
        onCpu.SKP(register: register)
    }
}

@objc class Sknp: NSObject, Instruction {
    let register: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "SKNP V\(register)"
        }
    }
    
    init(_ register: UInt8) {
        self.register = register
    }
    
    func execute(onCpu: Cpu) {
        onCpu.SKNP(register: register)
    }
}

@objc class Lddt: NSObject, Instruction {
    let register: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "LD V\(register), DT"
        }
    }
    
    init(_ register: UInt8) {
        self.register = register
    }
    
    func execute(onCpu: Cpu) {
        onCpu.LD(register: register)
    }
}


@objc class Ldk: NSObject, Instruction {
    let register: UInt8
    let advance = true
    let pause = true
    
    var mnemonic: String {
        get {
            return "LD V\(register), K"
        }
    }
    
    init(_ register: UInt8) {
        self.register = register
    }
    
    func execute(onCpu: Cpu) {
        onCpu.LDK(register: register)
    }
}

@objc class Ldrdt: NSObject, Instruction {
    let register: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "LD DT, V\(register)"
        }
    }
    
    init(_ register: UInt8) {
        self.register = register
    }
    
    func execute(onCpu: Cpu) {
        onCpu.DT(register: register)
    }
}

@objc class St: NSObject, Instruction {
    let register: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "LD ST, V\(register)"
        }
    }
    
    init(_ register: UInt8) {
        self.register = register
    }
    
    func execute(onCpu: Cpu) {
        onCpu.ST(register: register)
    }
}

@objc class Addi: NSObject, Instruction {
    let register: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "ADD I, V\(register)"
        }
    }
    
    init(_ register: UInt8) {
        self.register = register
    }
    
    func execute(onCpu: Cpu) {
        onCpu.ADD(register: register)
    }
}

@objc class Ldf: NSObject, Instruction {
    let register: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "LD F, V\(register)"
        }
    }
    
    init(_ register: UInt8) {
        self.register = register
    }
    
    func execute(onCpu: Cpu) {
        onCpu.LDS(register: register)
    }
}

@objc class Ldb: NSObject, Instruction {
    let register: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "LD B, V\(register)"
        }
    }
    
    init(_ register: UInt8) {
        self.register = register
    }
    
    func execute(onCpu: Cpu) {
        onCpu.BCD(register: register)
    }
}

@objc class Ldir: NSObject, Instruction {
    let register: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "LD [I], V\(register)"
        }
    }
    
    init(_ register: UInt8) {
        self.register = register
    }
    
    func execute(onCpu: Cpu) {
        onCpu.STO(register: register)
    }
}

@objc class Ldri: NSObject, Instruction {
    let register: UInt8
    let advance = true
    let pause = false
    
    var mnemonic: String {
        get {
            return "LD V\(register), [I]"
        }
    }
    
    init(_ register: UInt8) {
        self.register = register
    }
    
    func execute(onCpu: Cpu) {
        onCpu.LDR(register: register)
    }
}

