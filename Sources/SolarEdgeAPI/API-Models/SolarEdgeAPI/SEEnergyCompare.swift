//
//  SEEnergyCompare.swift
//
//
//  Created by Andre Albach on 01.09.23.
//

import Foundation

/// Will provide energy compare data for differnet time ranges (month, quarter and year).
/// This data is best when compare charts are used
public struct SEEnergyCompare {
    /// The energy data based on months
    public let month: SEEnergyData
    /// The energy data based on quarters
    public let quarter: SEEnergyData
    /// The energy data based on years
    public let year: SEEnergyData
}

extension SEEnergyCompare {
    /// Accumulated energy data for a certain time range
    public struct SEEnergyData {
        /// The time interval for the x axis.
        /// For monthly comparison it is "01", "02", ..., "12"
        /// For quarter comparison it is "Q1", "Q2", "Q3", "Q4"
        /// For year comparison it is "2023", "2024", ...
        public let xAxis: [String]
        /// The Keys will be the years.
        /// The values is another dictionary in which the keys will be from `xAxis` (a value might not exist for a certain xAxis value. Can happen when pv was installed outside of january) and the values will be the actual energy value in Wh.
        public let values: [String : [String : Int]]
    }
}
