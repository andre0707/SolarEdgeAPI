//
//  SEMOverview.swift
//  
//
//  Created by Andre Albach on 26.03.23.
//

import Foundation

/// The overview data of a site
public struct SEMOverview: Codable {
    public let lastUpdateTime: Date
    public let lifeTimeData: RevenueDataPoint
    // Should be rather: this year
    public let lastYearData: RevenueDataPoint
    // Should be rather: this month
    public let lastMonthData: RevenueDataPoint
    // Should be rather: today
    public let lastDayData: RevenueDataPoint
    public let currentPower: [String: Double]
    public let measuredBy: String
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let _lastUpdateTime = try container.decode(String.self, forKey: .lastUpdateTime)
        guard let lastUpdateTime = DateFormatter.apiDateTime.date(from: _lastUpdateTime) else { throw SolarEdgeAPIError.decoding("Invalid date") }
        self.lastUpdateTime = lastUpdateTime
        self.lifeTimeData = try container.decode(RevenueDataPoint.self, forKey: .lifeTimeData)
        self.lastYearData = try container.decode(RevenueDataPoint.self, forKey: .lastYearData)
        self.lastMonthData = try container.decode(RevenueDataPoint.self, forKey: .lastMonthData)
        self.lastDayData = try container.decode(RevenueDataPoint.self, forKey: .lastDayData)
        self.currentPower = try container.decode([String: Double].self, forKey: .currentPower)
        self.measuredBy = try container.decode(String.self, forKey: .measuredBy)
    }
}


extension SEMOverview {
    public struct RevenueDataPoint: Codable {
        public let energy: Double
        public let revenue: Double?
    }
}
