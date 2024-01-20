//
//  SortOrder.swift
//
//
//  Created by Andre Albach on 20.01.24.
//

#if os(Linux)
import Foundation

/// On Linux systems, the `SortOrder` enum is not implemented.
/// This will add the enum
@frozen public enum SortOrder : Hashable, Codable, Sendable {
    
    /// The ordering where if compare(a, b) == .orderedAscending,
    /// a is placed before b.
    case forward
    
    /// The ordering where if compare(a, b) == .orderedAscending,
    /// a is placed after b.
    case reverse
}

#endif
