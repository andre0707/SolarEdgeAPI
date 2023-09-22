//
//  SEEnergyOverview.swift
//
//
//  Created by Andre Albach on 03.09.23.
//

import Foundation

/// The energy overview
public struct SEEnergyOverview: Codable {
    /// The time period in which the energy was produced
    public let timePeriod: SETimePeriod
    /// The energy produced in `timePeriod`.
    /// The unit of the value is Wh.
    public let energy: Double
    /// The revenue made from the energy
//    public let revenue: ?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let _timePeriod = try container.decode(String.self, forKey: .timePeriod)
        guard let timePeriod = SETimePeriod(rawValue: _timePeriod) else { throw SolarEdgeAPIError.decoding("Invalid time period") }
        self.timePeriod = timePeriod
        self.energy = try container.decode(Double.self, forKey: .energy)
    }
}

extension SEEnergyOverview {
    /// A list of all the available time periods
    public enum SETimePeriod: String, Codable {
        case lifeTime = "LIFE_TIME"
        case lastYear = "LAST_YEAR"
        case lastMonth = "LAST_MONTH"
        case lastDay = "LAST_DAY"
    }
}
