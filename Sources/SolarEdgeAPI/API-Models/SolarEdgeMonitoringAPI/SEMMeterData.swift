//
//  SEMMeterData.swift
//  
//
//  Created by Andre Albach on 26.03.23.
//

import Foundation

/// A meter provides detailed measurement infomration
public struct SEMMeterData: Codable {
    public let type: MeterType
    public let values: [SEMDataPoint]
    
    /// The coding keys
    enum CodingKeys: String, CodingKey {
        case type
        case values
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.type = MeterType(rawValue: try container.decode(String.self, forKey: .type)) ?? .unknown
        self.values = try container.decode([SEMDataPoint].self, forKey: .values)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(values, forKey: .values)
    }
}


extension SEMMeterData {
    
    public enum MeterType: String {
        case consumption = "Consumption"
        case purchased = "Purchased"
        case production = "Production"
        case selfConsumption = "SelfConsumption"
        case feedIn = "FeedIn"
        
        case unknown = "Unknown"
    }
}
