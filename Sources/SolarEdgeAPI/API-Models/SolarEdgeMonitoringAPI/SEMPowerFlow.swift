//
//  SEMPowerFlow.swift
//  
//
//  Created by Andre Albach on 30.04.23.
//

import Foundation

/// A power flow. This contains information about power coming from the PV, load and grid.
public struct SEMPowerFlow: Codable {
    public let updateRefreshRate: Int
    public let unit: String
    public let grid: PowerFlowDetail
    public let load: PowerFlowDetail
    public let pv: PowerFlowDetail
    
    /// The coding keys
    enum CodingKeys: String, CodingKey {
        case updateRefreshRate
        case unit
        case grid = "GRID"
        case load = "LOAD"
        case pv = "PV"
    }
}


extension SEMPowerFlow {
    /// A detail value of a power flow
    public struct PowerFlowDetail: Codable {
        public let status: String
        public let currentPower: Double
    }
}


extension SEMPowerFlow: CustomStringConvertible {
    public var description: String {
        """
        Current power flow:
        PV: \(pv.currentPower.formatted())\(unit)
        House uses: \(load.currentPower.formatted())\(unit)
        Grid: \(grid.currentPower.formatted())\(unit)
        
        \(isPowerImported ? "importing" : "exporting") \(grid.currentPower.formatted())\(unit)
        """
    }
}


extension SEMPowerFlow {
    
    /// Indicator, if power is currently imported
    public var isPowerImported: Bool { pv.currentPower < load.currentPower }
    
    /// Indicator, if power is currently exported
    public var isPowerExported: Bool { pv.currentPower > load.currentPower }
    
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
