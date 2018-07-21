//
//  ByteCell.swift
//  Chip8
//
//  Created by Alexander Scown on 20/7/18.
//  Copyright © 2018 Alex Scown. All rights reserved.
//

import Foundation

class ByteCell: NSObject {
    @objc dynamic let address: Int
    @objc dynamic let byte: UInt8
    
    init(_ address: Int, _ byte: UInt8) {
        self.address = address
        self.byte = byte
    }
}
