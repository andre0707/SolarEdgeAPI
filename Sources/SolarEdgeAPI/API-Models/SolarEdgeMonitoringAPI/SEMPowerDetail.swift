//
//  SEMPowerDetail.swift
//  
//
//  Created by Andre Albach on 05.04.23.
//

import Foundation

/// A power detail
public struct SEMPowerDetail: Codable {
    public let timeUnit: TimeUnit
    public let unit: String
    public let meters: [SEMMeterData]
    
    /// The coding keys
    enum CodingKeys: String, CodingKey {
        case timeUnit
        case unit
        case meters
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.timeUnit = TimeUnit(rawValue: try container.decode(String.self, forKey: .timeUnit)) ?? .unknown
        self.unit = try container.decode(String.self, forKey: .unit)
        self.meters = try container.decode([SEMMeterData].self, forKey: .meters)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(timeUnit.rawValue, forKey: .timeUnit)
        try container.encode(unit, forKey: .unit)
        try container.encode(meters, forKey: .meters)
    }
}
