//
//  DataPoint.swift
//  
//
//  Created by Andre Albach on 26.03.23.
//

import Foundation

/// A single data point struct.
/// This is used in `Energy` and `Power`
public struct DataPoint: Codable {
    public let date: Date
    public let value: Double?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let _date = try container.decode(String.self, forKey: .date)
        self.date = DateFormatter.apiDateTime.date(from: _date) ?? Date.distantPast
        
        self.value = try container.decodeIfPresent(Double.self, forKey: .value)
    }
}
