//
//  SiteRequestParameter.swift
//  
//
//  Created by Andre Albach on 26.03.23.
//

import Foundation

/// The request for sites allows filtering and sorting.
/// This struct can be used to provide these information
public struct SiteRequestParameter {
    public let size: Int?
    public let startIndex: Int?
    public let searchText: String?
    public let sortProperty: SortProperty?
    public let sortOrder: SortOrder?
    public let status: SiteStatus?
    
    /// A list of site properites to sort by
    public enum SortProperty: String {
        case name
        case country
        case state
        case city
        case address
        case zip
        case status
        case peakPower
        case installationDate
        case amount
        case maxSeverity
        case creationTime
    }
    
    /// A list of all the status a site can have.
    public enum SiteStatus: String {
        case active
        case pending
        case disabled
        case all
    }
    
    /// Will create and return the URLQueryItems from `self`
    public var urlQueryItems: [URLQueryItem]? {
        var queryItems: [URLQueryItem] = []
        if let size {
            queryItems.append(URLQueryItem(name: "size", value: "\(size)"))
        }
        if let startIndex {
            queryItems.append(URLQueryItem(name: "startIndex", value: "\(startIndex)"))
        }
        if let searchText {
            queryItems.append(URLQueryItem(name: "searchText", value: "\(searchText)"))
        }
        if let sortProperty {
            queryItems.append(URLQueryItem(name: "sortProperty", value: "\(sortProperty.rawValue)"))
        }
        if let sortOrder {
            queryItems.append(URLQueryItem(name: "sortOrder", value: "\(sortOrder  == .forward ? "ASC" : "DESC")"))
        }
        if let status {
            queryItems.append(URLQueryItem(name: "status", value: "\(status.rawValue)"))
        }
        
        return queryItems.isEmpty ? nil : queryItems
    }
    
    /// Initialisation
    public init(size: Int?, startIndex: Int?, searchText: String?, sortProperty: SortProperty?, sortOrder: SortOrder?, status: SiteStatus?) {
        self.size = size
        self.startIndex = startIndex
        self.searchText = searchText
        self.sortProperty = sortProperty
        self.sortOrder = sortOrder
        self.status = status
    }
}
