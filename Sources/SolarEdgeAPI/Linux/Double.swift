//
//  Double.swift
//
//
//  Created by Andre Albach on 20.01.24.
//

#if os(Linux)
import Foundation

/// On Linux systems, the `formatted()` function is not implemented on `Double`.
/// This extension adds the `formattedd()` function for Linux,
extension Double {
    func formatted() -> String {
        String(format: "%f", self)
    }
}

#endif
