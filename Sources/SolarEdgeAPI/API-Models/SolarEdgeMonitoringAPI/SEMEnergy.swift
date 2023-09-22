//
//  SEMEnergy.swift
//  
//
//  Created by Andre Albach on 26.03.23.
//

import Foundation

/// The energy measurements which come from a `Site`
public struct SEMEnergy: Codable {
    public let timeUnit: TimeUnit
    public let unit: String
    public let values: [SEMDataPoint]
    
    /// The coding keys
    enum CodingKeys: String, CodingKey {
        case timeUnit
        case unit
        case values
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.timeUnit = TimeUnit(rawValue: try container.decode(String.self, forKey: .timeUnit)) ?? .unknown
        self.unit = try container.decode(String.self, forKey: .unit)
        self.values = try container.decode([SEMDataPoint].self, forKey: .values)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(timeUnit.rawValue, forKey: .timeUnit)
        try container.encode(unit, forKey: .unit)
        try container.encode(values, forKey: .values)
    }
}


extension SEMEnergy {
    
    /// A single energy time period data point
    public struct TimePeriodDataPoint: Codable {
        public let energy: Double
        public let unit: String
    }
}


extension SEMEnergy.TimePeriodDataPoint: CustomStringConvertible {
    /// The description of the data point
    public var description: String {
        let unit = Unit(symbol: self.unit)
        
        let measurement = Measurement(value: energy, unit: unit)
        
        return MeasurementFormatter().string(from: measurement)
    }
}
