//
//  EnergyRequestParameter.swift
//  
//
//  Created by Andre Albach on 05.04.23.
//

import Foundation

/// The request parameters for site energy measurements.
/// Will not evaluate the time components of `startDate` and `endDate`
public struct EnergyRequestParameter {
    /// Will not evaluate the time components
    public let startDate: Date
    /// Will not evaluate the time components
    public let endDate: Date
    public let timeUnit: TimeUnit
    
    /// Will create and return the URLQueryItems from `self`
    public var urlQueryItems: [URLQueryItem] {
        return [
            URLQueryItem(name: "startDate", value: DateFormatter.apiDate.string(from: startDate)),
            URLQueryItem(name: "endDate", value: DateFormatter.apiDate.string(from: endDate)),
            URLQueryItem(name: "timeUnit", value: timeUnit.rawValue),
        ]
    }
    
    /// Initialisation
    public init(startDate: Date, endDate: Date, timeUnit: TimeUnit) {
        self.startDate = startDate
        self.endDate = endDate
        self.timeUnit = timeUnit
    }
}
