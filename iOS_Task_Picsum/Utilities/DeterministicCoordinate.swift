//
//  DeterministicCoordinate.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//

import Foundation

enum DeterministicCoordinate {
    static func from(seed: String) -> (lat: Double, lon: Double) {
        var hash = 5381
        for b in seed.utf8 {
            hash = ((hash << 5) &+ hash) &+ Int(b)
        }
        let a = UInt(bitPattern: hash)
        let lat = Double(Int(a & 0xFFFF) % 121) - 60.0
        let lon = Double(Int((a >> 16) & 0xFFFFFFFF) % 360) - 180.0
        return (lat, lon)
    }
}
