//
//  SEMComponent.swift
//  
//
//  Created by Andre Albach on 05.04.23.
//

import Foundation

/// A single component like an inverterter/SMI
public struct SEMComponent: Codable {
    public let name: String
    public let manufacturer: String
    public let model: String
    public let serialNumber: String
//    public let kWpDC: String?
}
