//
//  EnergyDetail.swift
//  
//
//  Created by Andre Albach on 26.03.23.
//

import Foundation

/// A energy detail
public struct EnergyDetail: Codable {
    public let timeUnit: TimeUnit
    public let unit: String
    public let meters: [MeterData]
    
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
        self.meters = try container.decode([MeterData].self, forKey: .meters)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(timeUnit.rawValue, forKey: .timeUnit)
        try container.encode(unit, forKey: .unit)
        try container.encode(meters, forKey: .meters)
    }
}


extension EnergyDetail {
    /// The meter data for purchased, if available
    public var purchased: MeterData? { meters.first { $0.type == .purchased } }
    
    /// The meter data for feed in, if available
    public var feedIn: MeterData? { meters.first { $0.type == .feedIn } }
    
    /// The meter data for self consumption, if available
    public var selfConsumption: MeterData? { meters.first { $0.type == .selfConsumption } }
    
    /// The meter data for production, if available
    public var production: MeterData? { meters.first { $0.type == .production } }
    
    /// The meter data for consumption, if available
    public var consumption: MeterData? { meters.first { $0.type == .consumption } }
}


extension EnergyDetail {
    /// The total purchased value, if available
    public var purchasedTotalValue: Double? {
        purchased?.values
            .compactMap({ $0.value })
            .reduce(0, +)
    }
    /// The total feed in value, if available
    public var feedInTotalValue: Double? {
        feedIn?.values
            .compactMap({ $0.value })
            .reduce(0, +)
    }
    /// The total self consumption value, if available
    public var selfConsumptionTotalValue: Double? {
        selfConsumption?.values
            .compactMap({ $0.value })
            .reduce(0, +)
    }
    /// The total production value, if available
    public var productionTotalValue: Double? {
        production?.values
            .compactMap({ $0.value })
            .reduce(0, +)
    }
    /// The total consumption value, if available
    public var consumptionTotalValue: Double? {
        consumption?.values
            .compactMap({ $0.value })
            .reduce(0, +)
    }
}


extension EnergyDetail {
    /// The percentage (rounded in whole percent; Value between 0 and 100) of the feed in energy
    public var feedInPercentage: Int? {
        guard let feedIn = feedInTotalValue,
            let production = productionTotalValue
        else { return nil }
        
        let percentage = feedIn / production * 100
        
        return Int(percentage.rounded())
    }
    
    /// The percentage (rounded in whole percent; Value between 0 and 100) of the self usage of the produced energy
    public var selfUsagePercentage: Int? {
        guard let selfConsumption = selfConsumptionTotalValue,
            let production = productionTotalValue
        else { return nil }
        
        let percentage = selfConsumption / production * 100
        
        return Int(percentage.rounded())
    }
    
    /// The percentage (rounded in whole percent; Value between 0 and 100) of the purchased energy
    public var purchasedPercentage: Int? {
        guard let purchased = purchasedTotalValue,
            let consumption = consumptionTotalValue
        else { return nil }
        
        let percentage = purchased / consumption * 100
        
        return Int(percentage.rounded())
    }
    
    /// The percentage (rounded in whole percent; Value between 0 and 100) of the purchased energy
    public var selfConsumptionPercentage: Int? {
        guard let selfConsumption = selfConsumptionTotalValue,
            let consumption = consumptionTotalValue
        else { return nil }
        
        let percentage = selfConsumption / consumption * 100
        
        return Int(percentage.rounded())
    }
}


extension EnergyDetail {
    /// The total purchased value, if available
    public var purchasedTotalValueDescription: String? {
        purchasedTotalValue?.formatted()
    }
    /// The total feed in value, if available
    public var feedInTotalValueDescription: String? {
        feedInTotalValue?.formatted()
    }
    /// The total self consumption value, if available
    public var selfConsumptionTotalValueDescription: String? {
        selfConsumptionTotalValue?.formatted()
    }
    /// The total production value, if available
    public var productionTotalValueDescription: String? {
        productionTotalValue?.formatted()
    }
    /// The total consumption value, if available
    public var consumptionTotalValueDescription: String? {
        consumptionTotalValue?.formatted()
    }
}
