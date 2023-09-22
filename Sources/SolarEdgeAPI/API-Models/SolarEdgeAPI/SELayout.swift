//
//  SELayout.swift
//
//
//  Created by Andre Albach on 31.08.23.
//

import Foundation


// MARK: - LayoutEnergy

/// The energy details of a single module in the layout.
/// Can be the data of a single photovoltaic module or the complete site. This is why sime variables are optional and might not be set
public struct SELayoutEnergy: Codable {
    /// The energy produced
    public let energy: Double
    /// The energy the module pproduced (available if it is a module)
    public let moduleEnergy: Double?
    /// The unsacaled energy (should be in Wh)
    public let unscaledEnergy: Double?
    /// The unit used for `energy` and `moduleEnergy`
    public let units: String
    /// The hex color for the module
    public let color: String
    /// The hex color for the group
    public let groupColor: String?
    // public let relayState
    public let cellularConnectionProperties: SECellularConnectionProperties?
}

extension SELayoutEnergy {
    /// Connection related properties
    public struct SECellularConnectionProperties: Codable {
        public let connectionType: String
        // public let connectionFailure
        public let connectable: Bool
    }
}


// MARK: - PhysicalLayout

/// The physical layout helps to draw the installed photovoltaic system.
/// It will describe the layout and also contain information about grouping of the pv modules.
/// The grouping is interesing to check for module failure, because modules within the same group should produce a similar amount of energy
public struct SEPhysicalLayout: Codable {
    /// The unique id. Should match the siteId
    public let fieldId: Int
    /// Information about the dimensions of the components when drawing the physical layout
    public let siteDimensions: SESiteDimension
    /// The pv modules can be bundled in multiple groups. If there are modules on both sides of a roof, this could be also two groups
    public let groups: [SEModuleGroup]
    /// The last publish date of the layout
    public let lastPublished: Date
    /// A list of all the invertres which are used in the layout
    public let inverters: [SEInverter]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.fieldId = try container.decode(Int.self, forKey: .fieldId)
        self.siteDimensions = try container.decode(SEPhysicalLayout.SESiteDimension.self, forKey: .siteDimensions)
        self.groups = try container.decode([SEPhysicalLayout.SEModuleGroup].self, forKey: .groups)
        let _lastPublished =  try container.decode(Double.self, forKey: .lastPublished) / 1000
        self.lastPublished = Date(timeIntervalSince1970: _lastPublished)
        self.inverters = try container.decode([SEPhysicalLayout.SEInverter].self, forKey: .inverters)
    }
}

extension SEPhysicalLayout {
    /// Alle the groups with all the ids of the modules which belong to a group
    public var groupIds: [[Int]] {
        groups.map { $0.modules.map { $0.id } }
    }
}

extension SEPhysicalLayout {
    /// A module group describes a group of modules
    public struct SEModuleGroup: Codable {
        /// Id of the group
        public let id: Int
        /// Position and size information of the group when drawing it
        public let rectangle: SERectangle
        /// The orientation of the modules in this group. Value could be "HORIZONTAL"
        public let moduleOrientation: String
        /// The tilt of the modules in this group when drawing them
        public let moduleTilt: Double
        /// The width of the modules in this group when drawing them
        public let moduleWidth: Double
        /// The height of the modules in this group when drawing them
        public let moduleHeight: Double
        /// The vertical spacing when drawing
        public let vSpacing: Int
        /// The vertical spacing when drawing
        public let hSpacing: Int
        /// Number of rows in the group
        public let rows: Int
        /// Number of columns in the group
        public let columns: Int
        /// The pv modules in the group
        public let modules: [SEModule]
        /// The ids of the inverters in the group
        public let invertersIds: [Int]
        /// The number of optimizers used in the group
        public let numOfOptimizers: Int
    }
    
    /// Information about a rectangle which can be drawn
    public struct SERectangle: Codable {
        /// The x coordinate
        public let x: Double
        /// The y coordinate
        public let y: Double
        /// The height of the rectangle
        public let height: Double
        /// The width of the rectangle
        public let width: Double
        /// The azimuth of the rectangle
        public let azimuth: Double
    }
    
    /// This is the structure of a single pv module
    public struct SEModule: Codable {
        /// The id of the module
        public let moduleId: Int
        /// The row of the group in which the module is
        public let row: Int
        /// The column of the group in which the module is
        public let column: Int
        /// Unique identfier
        public let id: Int
        /// The id of the inverter the module is connected to
        public let inverterId: Int
    }
    
    /// Dimension information about the site
    public struct SESiteDimension: Codable {
        /// Vertical spacing
        public let vSpacing: Int
        /// Horizontal spacing
        public let hSpacing: Int
        /// A map of all the dimensions of the components
        public let dimensionMap: SEDimensionMap
    }
    
    /// A structure which describes an inverter in the layout
    public struct SEInverter: Codable {
        /// The unique id of the inverter
        public let id: Int
        /// The type of the inverter
        public let type: String
        /// The drawing rectangle information of the inverter
        public let rectangle: SERectangle
    }
}

extension SEPhysicalLayout.SESiteDimension {
    /// Holds information about the dimensions of all the components
    public struct SEDimensionMap: Codable {
        /// The size of the inverter
        public let inverter: SEDimensionMap.SESize
        /// The size of a single module
        public let module: SEDimensionMap.SESize
        /// The size of the smi
        public let smi: SEDimensionMap.SESize
        
        /// The coding keys
        enum CodingKeys: String, CodingKey {
            case inverter = "Inverter"
            case module = "Module"
            case smi = "SMI"
        }
    }
}

extension SEPhysicalLayout.SESiteDimension.SEDimensionMap {
    /// A object which describes a size
    public struct SESize: Codable {
        /// The width
        public let width: Double
        /// The height
        public let height: Double
    }
}


// MARK: - LogicalLayout

/// The logical layout of the installed photovoltaic system.
public struct SELogicalLayout: Codable {
    /// The site to which the layout belongs
    public let siteId: Int
    /// ?
    public let expanded: Bool
    /// ?
    public let playback: Bool
    /// ?
    public let hasPhysical: Bool
    /// The logical tree structure of the layout
    public let logicalTree: SELogicalTree
    /// The energy data of the modules
    public let reportersData: [String : SELayoutEnergy]
}

extension SELogicalLayout {
    /// The logical tree structure
    public struct SELogicalTree: Codable {
        /// Data about the tree item
        public let data: SEChild.SEChildData?
        /// Number of child, but does not necessaryly match `childIds.count`
        public let numberOfChilds: Int
        /// The list of ids of the children
        public let childIds: [Int]
        /// The list of children items
        public let children: [SEChild]
    }
}

extension SELogicalLayout.SELogicalTree {
    public struct SEChild: Codable {
        public let data: SEChildData
        public let numberOfChilds: Int
        public let childIds: [Int]
        public let children: [SEChild]
    }
}

extension SELogicalLayout.SELogicalTree.SEChild {
    public struct SEChildData: Codable {
        public let id: Int
        public let serialNumber: String?
        public let name: String
        public let displayName: String
        public let relativeOrder: Int
        public let type: String
        public let operationsKey: Int
    }
}
