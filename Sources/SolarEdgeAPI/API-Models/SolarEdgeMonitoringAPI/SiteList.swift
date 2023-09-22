//
//  SiteList.swift
//  
//
//  Created by Andre Albach on 26.03.23.
//

import Foundation

/// A list of sites
public struct SiteList: Codable {
    public let count: Int
    public let site: [Site]
}
