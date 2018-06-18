//
//  ViewController.swift
//  Chip8
//
//  Created by Alexander Scown on 25/5/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet var pixelView: PixelView?
    @IBOutlet var chip8View: Chip8View?
    @objc dynamic var canRun: Bool = false
    @objc dynamic var canStop: Bool = false
    @objc dynamic var isRunning: Bool = false
    @objc dynamic var filePath: String = ""
    
    var player = AVAudioPlayer()
    
    var ram = [UInt8]()    
    var V = [UInt8]()
    var I: UInt16 = 0
    var delay: UInt8 = 0
    var sound: UInt8 = 0
    var PC: UInt16 = 0
    var SP: Int8 = 0
    var stack = [UInt16]()
    
    var delayAccess: DispatchTime = DispatchTime.now()
    var soundAccess: DispatchTime = DispatchTime.now()
    var haltFlag = false
    var expectedKey: UInt8?
    
    var keys = Array(repeating: false, count: 16)
    
    let keyValues: Dictionary<String, UInt8> = [
        "1": 1,
        "2": 2,
        "3": 3,
        "4": 0xC,
        "q": 4,
        "w": 5,
        "e": 6,
        "r": 0xD,
        "a": 7,
        "s": 8,
        "d": 9,
        "f": 0xE,
        "z": 0xA,
        "x": 0,
        "c": 0xB,
        "v": 0xF
    ]
    
    let queue = DispatchQueue(label: "space.scown.chip8", qos: .utility)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path: String? = Bundle.main.path(forResource: "440", ofType: "wav")
        
        chip8View!.delegate = self
        
        do {
            try player = AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: path!))
            player.numberOfLoops = -1
        } catch {}
    }
    
    @IBAction func openFile(sender: AnyObject) {
        let dialog = NSOpenPanel();
        
        dialog.title = "Open...";
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.allowsMultipleSelection = false;
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let result = dialog.url {
                filePath = result.path
                
                canRun = true
                canStop = false
                isRunning = false
            }
        }
    }
    
    @IBAction func run(sender: AnyObject) {
        isRunning = true
        canRun = false
        canStop = true
        
        chip8View!.becomeFirstResponder()
        
        resetEmulator()
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedIfSafe)
            
            let program = data[0 ..< min(4096 - 512, data.count)]
            
            ram.replaceSubrange(512 ..< 512 + program.count, with: program)
            
            self.player.prepareToPlay()
            
            execute()
        } catch {}
    }
    
    @IBAction func halt(sender: AnyObject) {
        if expectedKey != nil {
            terminate()
        }
        else {
            haltFlag = true
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if isRunning {
            if let string = event.charactersIgnoringModifiers {
                queue.async {
                    print("keydown \(string)")
                    self.setKeys(string, true)
                }
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if isRunning {
            if let string = event.charactersIgnoringModifiers {
                queue.async {
                    print("keyup \(string)")
                    self.setKeys(string, false)
                }
            }
        }
    }
    
    private func setKeys(_ string: String, _ flag: Bool) {
        for key in string {
            if let keyByte = keyValues[String(key)] {
                keys[Int(keyByte)] = flag
                
                if flag {
                    if let keyRegister = self.expectedKey {
                        self.V[Int(keyRegister)] = keyByte
                        self.expectedKey = nil
                        
                        DispatchQueue.main.async {
                            self.execute()
                        }
                    }
                }
            }
        }
    }
    
    private func terminate() {
        haltFlag = false
        
        player.stop()
        self.chip8View!.resignFirstResponder()
        
        isRunning = false
        canRun = true
        canStop = false
    }
    
    private func execute() {
        if haltFlag {
            terminate()
            
            return
        }
        
        queue.async {
            if self.sound > 0 {
                DispatchQueue.main.async {
                    self.player.play()
                }
            }
            else if self.player.isPlaying {
                DispatchQueue.main.async {
                    self.player.pause()
                }
            }
            
            let now = DispatchTime.now()
            
            if (self.delay > 0) {
                var difference = now.rawValue - self.delayAccess.rawValue
                
                while difference > 16 * 1_000_000 && self.delay > 0 {
                    self.delay -= 1
                    difference -= 16 * 1_000_000
                    self.delayAccess = now
                }
                
            }
            
            if (self.sound > 0) {
                var difference = now.rawValue - self.soundAccess.rawValue
                
                while difference > 16 * 1_000_000 && self.sound > 0 {
                    self.sound -= 1
                    difference -= 16 * 1_000_000
                    self.soundAccess = now
                }
                
            }
            
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
            self.pixelView!.clear()
        }
    }
    
    private func RET() {
        print("RET")
        
        self.PC = self.stack[Int(self.SP)]
        self.SP -= 1
    }
    
    private func JP(address: UInt16) {
        print("JP \(address)")
        
        self.PC = address
    }
    
    private func CALL(address: UInt16) {
        print("CALL \(address)")
        
        self.SP += 1
        self.stack[Int(self.SP)] = PC
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
        
        let sprite = accessRam(address: Int(self.I), length: Int(length))
        
        print(sprite)
                
        DispatchQueue.main.sync {
            let collision = self.pixelView!.drawSprite(sprite, atRow: Int(self.V[Int(registerY)]), andColumn: Int(self.V[Int(registerX)]))
            
            self.V[0xF] = collision ? 1 : 0
            
            if collision {
                print("collision!")
            }
        }
        
    }
    
    private func SKP(register: UInt8) {
        print("SKP \(register)")
        
        if keys[Int(V[Int(register)])] {
            print("true")
            self.PC += 2
        }
    }
    
    private func SKNP(register: UInt8) {
        print("SKNP \(register) \(V[Int(register)])")
        
        if !keys[Int(V[Int(register)])] {
            print("true")
            self.PC += 2
        }
    }
    
    private func LD(register: UInt8) {
        print("LD DELAY \(register)")
        
        V[Int(register)] = delay
    }
    
    private func LDK(register: UInt8) {
        print("LDK \(register)")
        
        expectedKey = register
    }
    
    private func DT(register: UInt8) {
        print("DT \(register)")
        
        delay = V[Int(register)]
        delayAccess = DispatchTime.now()
    }
    
    private func ST(register: UInt8) {
        print("ST \(register)")
        
        sound = V[Int(register)]
        soundAccess = DispatchTime.now()
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
    
    private func resetEmulator() {
        ram = [
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
        ] + [UInt8](repeating: 0, count: 4096 - 80)
        
        V = [UInt8](repeating: 0, count: 16)
        I = 0
        delay = 0
        sound = 0
        PC = 512
        SP = -1
        stack = [UInt16](repeating: 0, count: 16)
        
        pixelView!.clear()
    }
    
    private func accessRam(address: Int, length: Int) -> [UInt8] {
        return Array(self.ram[address ..< address + length])
    }
    
    private func getNextInstruction() -> (UInt8, UInt8, UInt8, UInt8) {
        let bytes = accessRam(address: Int(self.PC), length: 2)
        
        return (bytes[0] >> 4, bytes[0] & 0xF, bytes[1] >> 4, bytes[1] & 0xF)
    }
    
    private func getAddress(_ i2: UInt8, _ i3: UInt8, _ i4: UInt8) -> UInt16 {
        return UInt16(i4) + 16 * UInt16(i3) + 256 * UInt16(i2)
    }
    
    private func getByte(_ hi: UInt8, _ lo: UInt8) -> UInt8 {
        return (hi << 4) + lo
    }
    
}

