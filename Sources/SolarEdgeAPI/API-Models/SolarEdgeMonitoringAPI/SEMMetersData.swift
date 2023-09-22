//
//  SEMMetersData.swift
//  
//
//  Created by Andre Albach on 07.04.23.
//

import Foundation

/// Meters data
public struct SEMMetersData: Codable {
    public let timeUnit: String
    public let unit: String
    public let meters: [MeterDetail]
}


extension SEMMetersData {
    /// Detailed data from a single meter
    public struct MeterDetail: Codable {
        public let meterSerialNumber: String
        public let connectedSolaredgeDeviceSN: String
        public let model: String
        public let meterType: String
        public let values: [SEMDataPoint]
    }
}
