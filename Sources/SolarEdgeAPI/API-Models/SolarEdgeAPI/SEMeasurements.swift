//
//  SEMeasurements.swift
//
//
//  Created by Andre Albach on 03.09.23.
//

import Foundation

/// The energy measurement.
/// It provides a summary which contains information about the whole time period as well as detailed measurement points.
public struct SEMeasurement: Codable {
    /// The summary of the measurement
    public let summary: SESummary
    /// The details of the measurements. We can hide this object and provide direct access to its members by computed properties
    private let _measurements: SEMeasurementDetail
    
    /// The coding keys
    enum CodingKeys: String, CodingKey {
        case summary
        case _measurements = "measurements"
    }
}

extension SEMeasurement {
    /// The measurement unit
    public var measurementUnit: SEMeasurementsUnit { _measurements.measurementUnit }
    /// The measurements which are a list of data points
    public var measurements: [SEDataPoint] { _measurements.measurementsList }
}

extension SEMeasurement {
    /// A summary of production and consumption measurements
    public struct SESummary: Codable {
        /// The unit for the measurements within the summary
        public let measurementUnit: SEMeasurementsUnit
        /// The total production in unit `measurementUnit`
        public let production: Double
        /// The summary details of the production
        public let productionSummary: SEProductionSummary
        /// The total consumption in unit `measurementUnit`
        public let consumption: Double
        /// The summary details of the consumption
        public let consumptionSummary: SEConsumptionSummary
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SEMeasurement.SESummary.CodingKeys> = try decoder.container(keyedBy: SEMeasurement.SESummary.CodingKeys.self)
            
            let _measurementUnit = try container.decode(String.self, forKey: .measurementUnit)
            guard let measurementUnit = SEMeasurementsUnit(rawValue: _measurementUnit) else { throw SolarEdgeAPIError.decoding("Invalid measurement unit") }
            self.measurementUnit = measurementUnit
            self.production = try container.decode(Double.self, forKey: .production)
            self.productionSummary = try container.decode(SEMeasurement.SEProductionSummary.self, forKey: .productionSummary)
            self.consumption = try container.decode(Double.self, forKey: .consumption)
            self.consumptionSummary = try container.decode(SEMeasurement.SEConsumptionSummary.self, forKey: .consumptionSummary)
        }
    }
}

extension SEMeasurement {
    /// The units used with the measurements
    public enum SEMeasurementsUnit: String, Codable {
        case wattHour = "WATT_HOUR"
        case watt = "WATT"
    }
}

extension SEMeasurement {
    /// The time periods used with the measurements
    public enum SETimePeriod: String, Codable {
        case day = "DAY"
        case week = "WEEK"
        case month = "MONTH"
        case year = "YEAR"
    }
}

extension SEMeasurement {
    /// Summary of all the production measurements
    public struct SEProductionSummary: Codable {
        /// The energy which was produced and went to the home
        public let productionToHome: Double?
        /// The energy which was produced and went to the home in percent
        public let productionToHomePercentage: Int?
        /// The energy which was produced and is unknown where it went
        public let productionUnknown: Double?
        /// The energy which was produced and is unknown where it went in percent
        public let productionUnknownPercentage: Int?
        /// The energy which was produced and went to the battery
        public let productionToBattery: Double?
        /// The energy which was produced and went to the battery in percent
        public let productionToBatteryPercentage: Int?
        /// The energy which was produced and went to the grid
        public let productionToGrid: Double?
        /// The energy which was produced and went to the grid in percent
        public let productionToGridPercentage: Int?
    }
}

extension SEMeasurement {
    /// Summary of all the consukption measurements
    public struct SEConsumptionSummary: Codable {
        /// The energy which was consumped and came from the battery
        public let consumptionFromBattery: Double?
        /// The energy which was consumped and came from the battery in percent
        public let consumptionFromBatteryPercentage: Int?
        /// The energy which was consumped and came from the pv
        public let consumptionFromSolar: Double?
        /// The energy which was consumped and came from the pv in percent
        public let consumptionFromSolarPercentage: Int?
        /// The energy which was self consumped
        public let selfConsumption: Double?
        /// The energy which was self consumped in percent
        public let selfConsumptionPercentage: Int?
        /// The energy which was consumed and came from an unknown source
        public let consumptionUnknown: Double?
        /// The energy which was consumed and came from an unknown source in percent
        public let consumptionUnknownPercentage: Int?
        /// The energy which was consumped and came from the grid
        public let consumptionFromGrid: Double?
        /// The energy which was consumped and came from the grid in percent
        public let consumptionFromGridPercentage: Int?
    }
}

extension SEMeasurement {
    /// The details of the measurements
    public struct SEMeasurementDetail: Codable {
        /// The unit all the data points use
        public let measurementUnit: SEMeasurementsUnit
        /// The list of all the data points
        public let measurementsList: [SEDataPoint]
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SEMeasurement.SEMeasurementDetail.CodingKeys> = try decoder.container(keyedBy: SEMeasurement.SEMeasurementDetail.CodingKeys.self)
            
            let _measurementUnit = try container.decode(String.self, forKey: .measurementUnit)
            guard let measurementUnit = SEMeasurementsUnit(rawValue: _measurementUnit) else { throw SolarEdgeAPIError.decoding("Invalid measurement unit") }
            self.measurementUnit = measurementUnit
            self.measurementsList = try container.decode([SEMeasurement.SEDataPoint].self, forKey: .measurementsList)
        }
    }
}

extension SEMeasurement {
    /// A single energy measurement data point
    public struct SEDataPoint: Codable {
        /// The time when the measurement took place
        public let measurementTime: Date
        /// The measured energy production at `measurementTime`
        public let production: Double?
        /// The summary of the production
        public let productionSummary: SEProductionSummary
        /// The measured energy consumed at `measurementTime`
        public let consumption: Double?
        /// The summary of the consumption
        public let consumptionSummary: SEConsumptionSummary
//        public let batteryLevel: ?
//        public let chargingPower: ?
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SEMeasurement.SEDataPoint.CodingKeys> = try decoder.container(keyedBy: SEMeasurement.SEDataPoint.CodingKeys.self)
            
            let _measurementTime = try container.decode(String.self, forKey: .measurementTime)
            guard let measurementTime = DateFormatter.apiDateTimeWithSeparator.date(from: _measurementTime) else { throw SolarEdgeAPIError.decoding("Invalid date") }
            self.measurementTime = measurementTime
            self.production = try container.decodeIfPresent(Double.self, forKey: .production)
            self.productionSummary = try container.decode(SEMeasurement.SEProductionSummary.self, forKey: .productionSummary)
            self.consumption = try container.decodeIfPresent(Double.self, forKey: .consumption)
            self.consumptionSummary = try container.decode(SEMeasurement.SEConsumptionSummary.self, forKey: .consumptionSummary)
        }
    }
}
