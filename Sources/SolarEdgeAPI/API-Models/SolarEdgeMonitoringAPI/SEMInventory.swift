//
//  SEMInventory.swift
//  
//
//  Created by Andre Albach on 05.04.23.
//

import Foundation

/// The inventory of a site
public struct SEMInventory: Codable {
    public let meters: [Meter]
    public let sensors: [Sensor]
    public let gateways: [Gateway]
    public let batteries: [Battery]
    public let inverters: [Inverter]
}


extension SEMInventory {
    /// A meter
    public struct Meter: Codable {
        public let name: String
        public let manufacturer: String?
        public let model: String?
        public let firmwareVersion: String
        public let connectedTo: String
        public let connectedSolaredgeDeviceSN: String
        public let type: String
        public let form: String
        public let serialNumber: String?
        
        enum CodingKeys: String, CodingKey {
            case name
            case manufacturer
            case model
            case firmwareVersion
            case connectedTo
            case connectedSolaredgeDeviceSN
            case type
            case form
            case serialNumber = "SN"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.name = try container.decode(String.self, forKey: .name)
            self.manufacturer = try container.decodeIfPresent(String.self, forKey: .manufacturer)
            self.model = try container.decodeIfPresent(String.self, forKey: .model)
            self.firmwareVersion = try container.decode(String.self, forKey: .firmwareVersion)
            self.connectedTo = try container.decode(String.self, forKey: .connectedTo)
            self.connectedSolaredgeDeviceSN = try container.decode(String.self, forKey: .connectedSolaredgeDeviceSN)
            self.type = try container.decode(String.self, forKey: .type)
            self.form = try container.decode(String.self, forKey: .form)
            self.serialNumber = try container.decodeIfPresent(String.self, forKey: .serialNumber)
        }
    }
    
    /// A sensor
    public struct Sensor: Codable {
        public let connectedSolaredgeDeviceSN: String
        public let id: String
        public let connectedTo: String
        public let category: String
        public let type: String
    }
    
    /// A gateway
    public struct Gateway: Codable {
        public let name: String
        public let serialNumber: String
        public let firmwareVersion: String
        
        enum CodingKeys: String, CodingKey {
            case name
            case serialNumber = "SN"
            case firmwareVersion
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.name = try container.decode(String.self, forKey: .name)
            self.serialNumber = try container.decode(String.self, forKey: .serialNumber)
            self.firmwareVersion = try container.decode(String.self, forKey: .firmwareVersion)
        }
    }
    
    /// A battery
    public struct Battery: Codable {
        public let name: String
        public let serialNumber: String
        public let manufacturer: String
        public let model: String
        public let nameplateCapacity: String
        public let firmwareVersion: String
        public let connectedTo: String
        public let connectedSolaredgeDeviceSN: String
        
        enum CodingKeys: String, CodingKey {
            case name
            case serialNumber = "SN"
            case manufacturer
            case model
            case nameplateCapacity
            case firmwareVersion
            case connectedTo
            case connectedSolaredgeDeviceSN
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.name = try container.decode(String.self, forKey: .name)
            self.serialNumber = try container.decode(String.self, forKey: .serialNumber)
            self.manufacturer = try container.decode(String.self, forKey: .manufacturer)
            self.model = try container.decode(String.self, forKey: .model)
            self.nameplateCapacity = try container.decode(String.self, forKey: .nameplateCapacity)
            self.firmwareVersion = try container.decode(String.self, forKey: .firmwareVersion)
            self.connectedTo = try container.decode(String.self, forKey: .connectedTo)
            self.connectedSolaredgeDeviceSN = try container.decode(String.self, forKey: .connectedSolaredgeDeviceSN)
        }
    }
    
    /// An inverter
    public struct Inverter: Codable {
        public let name: String
        public let manufacturer: String
        public let model: String
        public let communicationMethod: String?
        public let cpuVersion: String?
        public let firmwareVersion: String?
        public let serialNumber: String
        public let connectedOptimizers: Int
        
        enum CodingKeys: String, CodingKey {
            case name
            case manufacturer
            case model
            case communicationMethod
            case cpuVersion
            case firmwareVersion
            case serialNumber = "SN"
            case connectedOptimizers
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.name = try container.decode(String.self, forKey: .name)
            self.manufacturer = try container.decode(String.self, forKey: .manufacturer)
            self.model = try container.decode(String.self, forKey: .model)
            self.communicationMethod = try container.decodeIfPresent(String.self, forKey: .communicationMethod)
            self.cpuVersion = try container.decodeIfPresent(String.self, forKey: .cpuVersion)
            self.firmwareVersion = try container.decodeIfPresent(String.self, forKey: .firmwareVersion)
            self.serialNumber = try container.decode(String.self, forKey: .serialNumber)
            self.connectedOptimizers = try container.decode(Int.self, forKey: .connectedOptimizers)
        }
    }
}
