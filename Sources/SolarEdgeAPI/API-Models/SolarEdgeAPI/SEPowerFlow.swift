//
//  SEPowerFlow.swift
//
//
//  Created by Andre Albach on 04.09.23.
//

import Foundation

/// The current power flow. This can be refreshed up to every 3 seconds
public struct SEPowerFlow: Codable {
    /// The represh rate in seconds
    public let updateRefreshRate: Int
    /// The unit of the power
    public let unit: String
    /// The load type
    public let loadType: SELoadType
    /// The connections which are currently active
    public let connections: [SEConnection]
    /// The grid connection
    public let grid: SEConnectionDetail
    /// The load connection
    public let load: SEConnectionDetail
    /// The pv connection
    public let pv: SEConnectionDetail
    /// The storage connection
    public let storage: SEConnectionDetail?
    /// The ev charger connection
    public let evCharger: SEConnectionDetail?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.updateRefreshRate = try container.decode(Int.self, forKey: .updateRefreshRate)
        self.unit = try container.decode(String.self, forKey: .unit)
        let _loadType = try container.decode(String.self, forKey: .loadType)
        guard let loadType = SELoadType(rawValue: _loadType) else { throw SolarEdgeAPIError.decoding("Unknown power flow load type: \(_loadType)") }
        self.loadType = loadType
        self.connections = try container.decode([SEPowerFlow.SEConnection].self, forKey: .connections)
        self.grid = try container.decode(SEConnectionDetail.self, forKey: .grid)
        self.load = try container.decode(SEConnectionDetail.self, forKey: .load)
        self.pv = try container.decode(SEConnectionDetail.self, forKey: .pv)
        self.storage = try container.decodeIfPresent(SEConnectionDetail.self, forKey: .storage)
        self.evCharger = try container.decodeIfPresent(SEConnectionDetail.self, forKey: .evCharger)
    }
}

extension SEPowerFlow {
    /// Indicator, if power is currently imported
    public var isPowerImported: Bool { connections.contains(where: { $0.isPowerImported  }) }
    
    /// Indicator, if power is currently exported
    public var isPowerExported: Bool { connections.contains(where: { $0.isPowerExported  }) }
    
    /// The amount of power which is currently imported.
    /// Power is only imported, if the house uses more power than the PV procudes.
    /// If nothing is imported, nil is returned
    public var currentImportedPower: Double? {
        guard isPowerImported else { return nil }
        return grid.currentPower
    }
    
    /// The amount of power which is currently exported.
    /// Power is only exported, if the house uses less power than the PV procudes.
    /// If nothing is exported, nil is returned
    public var currentExportedPower: Double? {
        guard isPowerExported else { return nil }
        return grid.currentPower
    }
}

extension SEPowerFlow {
    /// A active connection of an power flow
    public struct SEConnection: Codable {
        /// The start point of the connection
        public let from: SEConnectionPoint
        /// The end point of the connection
        public let to: SEConnectionPoint
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            let _from = try container.decode(String.self, forKey: .from)
            guard let from = SEConnectionPoint(rawValue: _from) else { throw SolarEdgeAPIError.decoding("Unknown power flow connection point: \(_from)") }
            self.from = from
            let _to = try container.decode(String.self, forKey: .to)
            guard let to = SEConnectionPoint(rawValue: _to) else { throw SolarEdgeAPIError.decoding("Unknown power flow connection point: \(_to)") }
            self.to = to
        }
    }
}

extension SEPowerFlow.SEConnection {
    /// Indicator, if power is currently imported
    public var isPowerImported: Bool { from == .grid && to == .load }
    
    /// Indicator, if power is currently exported
    public var isPowerExported: Bool { from == .load && to == .grid }
}

extension SEPowerFlow {
    /// A list of all the known connection points of a power flow
    public enum SEConnectionPoint: String, Codable {
        case grid = "Grid"
        case load = "Load"
        case pv = "PV"
//        case storage = "Storage" // Not clear if this is the correct name
//        case evCharger = "EvCharger" // Not clear if this is the correct name
    }
}

extension SEPowerFlow {
    /// Detail information about the connection
    public struct SEConnectionDetail: Codable {
        /// The status of the connection
        public let status: SEStatus
        /// The current power which flows on this connection
        public let currentPower: Double
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            let _status = try container.decode(String.self, forKey: .status)
            guard let status = SEStatus(rawValue: _status) else { throw SolarEdgeAPIError.decoding("Unknown power flow status: \(_status)") }
            self.status = status
            self.currentPower = try container.decode(Double.self, forKey: .currentPower)
        }
    }
}

extension SEPowerFlow.SEConnectionDetail {
    /// The list of the known status a connection can have
    public enum SEStatus: String, Codable {
        case active = "Active"
        case idle = "Idle"
    }
}

extension SEPowerFlow {
    /// The list of the known load type of the power flow
    public enum SELoadType: String, Codable {
        case residential = "Residential"
    }
}
