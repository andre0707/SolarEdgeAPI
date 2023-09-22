//
//  SolarEdgeMonitoringAPI.swift
//
//  Created by Andre Albach on 26.03.23.
//

import Foundation

/// The user agent which is used
fileprivate let userAgent = "SolarEdge Monitoring API for Swift"

/// Namespace for all the monitoring API functions
public enum SolarEdgeMonitoringAPI {
    
    /// The base url address for the monitoring api calls
    static private let monitoringBaseURL = "https://monitoringapi.solaredge.com"
    
    /// The response format.
    /// By default `json` is used.
    /// Not all API endpoints support all requests. An error will be thrown if the format is not available for the request.
    public enum ResponseFormat: String {
        case json = "application/json"
        case xml = "application/xml"
        case csv = "text/csv"
    }
}


// MARK: - Async Functions

public extension SolarEdgeMonitoringAPI {
    
    // MARK: - sites
    
    /// Will return all the sites matching the `requestParameter` and the `apiKey`
    /// - Parameters:
    ///   - requestParameter: OPtional the request parameter to specify which sites are needed
    ///   - apiKey: The api key to access the API
    /// - Returns: The list of sites which match the API request
    static func sites(matching requestParameter: SiteRequestParameter? = nil, apiKey: String) async throws -> [Site] {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/sites/list"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        do {
            struct SiteListResponse: Codable {
                let sites: SiteList
            }
            
            return try JSONDecoder().decode(SiteListResponse.self, from: data).sites.site
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - siteDetail
    
    /// Will return the details for the site with the passed in `siteId`.
    /// - Parameters:
    ///   - siteId: The id of the site for which details are needed
    ///   - apiKey: The api key to access the API
    /// - Returns: The detail information for the site matching the API request
    static func siteDetail(for siteId: Int, apiKey: String) async throws -> Site {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/details"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct SiteDetailsResponse: Codable {
            let details: Site
        }
        
        do {
            return try JSONDecoder().decode(SiteDetailsResponse.self, from: data).details
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
 
    
    // MARK: - siteData
    
    /// Will return the energy production start and end dates of the site
    /// - Parameters:
    ///   - siteId: The id of the site for which details are needed
    ///   - apiKey: The api key to access the API
    /// - Returns: The date period if available
    static func siteData(for siteId: Int, apiKey: String) async throws -> (startDate: Date?, endDate: Date?) {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/dataPeriod"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct SiteDataPeriodResponse: Codable {
            let startDate: Date?
            let endDate: Date?
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                if let _startDate = try container.decodeIfPresent(String.self, forKey: .startDate) {
                    if let dataTime = DateFormatter.apiDateTime.date(from: _startDate) {
                        self.startDate = dataTime
                    } else {
                        self.startDate = DateFormatter.apiDate.date(from: _startDate)
                    }                } else {
                    self.startDate = nil
                }
                if let _endDate = try container.decodeIfPresent(String.self, forKey: .endDate) {
                    if let dateTime = DateFormatter.apiDateTime.date(from: _endDate) {
                        self.endDate = dateTime
                    } else {
                        self.endDate = DateFormatter.apiDate.date(from: _endDate)
                    }
                } else {
                    self.endDate = nil
                }
            }
        }
        
        struct SiteDataResponse: Codable {
            let dataPeriod: SiteDataPeriodResponse
        }
        
        do {
            let dataPeriod = try JSONDecoder().decode(SiteDataResponse.self, from: data).dataPeriod
            return (dataPeriod.startDate, dataPeriod.endDate)
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - energy
    
    /// Will return the energy for the site with the passed in `siteId`, based on the `energyParameter`
    /// - Parameters:
    ///   - siteId: The id of the site for which the enery is needed
    ///   - energyParameter: The parameters for the energy result. Specify a start date, end date and interval for which the data is needed
    ///   - apiKey: The api key to access the API
    /// - Returns: The energy produced by the site matching the request parameter
    static func energy(for siteId: Int, using energyParameter: EnergyRequestParameter, apiKey: String) async throws -> SEMEnergy {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/energy"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        components.queryItems?.append(contentsOf: energyParameter.urlQueryItems)
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct EnergyResponse: Codable {
            let energy: SEMEnergy
        }
        
        do {
            return try JSONDecoder().decode(EnergyResponse.self, from: data).energy
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - totalEnergy
    
    /// Will return the total energy for the site with the passed in `siteId` during the time period between `startDate` and `endDate`
    /// - Parameters:
    ///   - siteId: The id of the site for which the total enery is needed
    ///   - startDate: Start date from which on the total energy is needed
    ///   - endDate: End date until when the total energy is needed
    ///   - apiKey: The api key to access the API
    /// - Returns: The total energy for the site for the time period
    static func totalEnergy(for siteId: Int, startDate: Date, endDate: Date, apiKey: String) async throws -> SEMEnergy.TimePeriodDataPoint {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/timeFrameEnergy"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "startDate", value: DateFormatter.apiDate.string(from: startDate)),
            URLQueryItem(name: "endDate", value: DateFormatter.apiDate.string(from: endDate))
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct TimeFrameEnergyResponse: Codable {
            let timeFrameEnergy: SEMEnergy.TimePeriodDataPoint
        }
        
        do {
            return try JSONDecoder().decode(TimeFrameEnergyResponse.self, from: data).timeFrameEnergy
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - power
    
    /// Will return the power the site produces in 15 minutes resolution.
    /// - Parameters:
    ///   - siteId: The id of the site for which the power is needed
    ///   - startTime: Start date and time from which on the power is needed
    ///   - endTime: End date and time until when the power is needed
    ///   - apiKey: The api key to access the API
    /// - Returns: The power for the site for the time period
    static func power(for siteId: Int, startTime: Date, endTime: Date, apiKey: String) async throws -> SEMPower {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/power"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "startTime", value: DateFormatter.apiDateTime.string(from: startTime)),
            URLQueryItem(name: "endTime", value: DateFormatter.apiDateTime.string(from: endTime))
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct PowerResponse: Codable {
            let power: SEMPower
        }
        
        do {
            return try JSONDecoder().decode(PowerResponse.self, from: data).power
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - overview
    
    /// Will return an overview for the site
    /// - Parameters:
    ///   - siteId: The id of the site for which the overview is needed
    ///   - apiKey: The api key to access the API
    /// - Returns: The overview for the site
    static func overview(for siteId: Int, apiKey: String) async throws -> SEMOverview {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/overview"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct OverviewResponse: Codable {
            let overview: SEMOverview
        }
        
        do {
            return try JSONDecoder().decode(OverviewResponse.self, from: data).overview
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - detailedPower
    
    /// Will return detailed power measurements from meters
    /// - Parameters:
    ///   - siteId: The id of the site for which the detailed power measurements are needed
    ///   - startTime: The start time for the measurements
    ///   - endTime: The end time for the measurements
    ///   - meterTypes: Optional a set of types for which data is wanted. If nil or empty, all meter types will be used
    ///   - apiKey: The api key to access the API
    /// - Returns: The detailed power measurements
    static func detailedPower(for siteId: Int, from startTime: Date, until endTime: Date, meterTypes: Set<SEMMeterData.MeterType>? = nil, apiKey: String) async throws -> SEMPowerDetail {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/powerDetails"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "startTime", value: DateFormatter.apiDateTime.string(from: startTime)),
            URLQueryItem(name: "endTime", value: DateFormatter.apiDateTime.string(from: endTime))
        ]
        if let meterTypes, !meterTypes.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "meters", value: meterTypes.map { $0.rawValue }.joined(separator: ",")))
        }
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct PowerDetailResponse: Codable {
            let powerDetails: SEMPowerDetail
        }
        
        do {
            return try JSONDecoder().decode(PowerDetailResponse.self, from: data).powerDetails
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - detailedEnergy
    
    /// Will return detailed energy measurements from meters
    /// - Parameters:
    ///   - siteId: The id of the site for which the detailed energy measurements are needed
    ///   - startTime: The start time for the measurements
    ///   - endTime: The end time for the measurements
    ///   - timeUnit: The time unit for the aggregation granularity
    ///   - meterTypes: Optional a set of types for which data is wanted. If nil or empty, all meter types will be used
    ///   - apiKey: The api key to access the API
    /// - Returns: The detailed energy measurements
    static func detailedEnergy(for siteId: Int, from startTime: Date, until endTime: Date, timeUnit: TimeUnit = .day, meterTypes: Set<SEMMeterData.MeterType>? = nil, apiKey: String) async throws -> SEMEnergyDetail {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/energyDetails"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "startTime", value: DateFormatter.apiDateTime.string(from: startTime)),
            URLQueryItem(name: "endTime", value: DateFormatter.apiDateTime.string(from: endTime)),
            URLQueryItem(name: "timeUnit", value: timeUnit.rawValue)
        ]
        if let meterTypes, !meterTypes.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "meters", value: meterTypes.map { $0.rawValue }.joined(separator: ",")))
        }
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct EnergyDetailResponse: Codable {
            let energyDetails: SEMEnergyDetail
        }
        
        do {
            return try JSONDecoder().decode(EnergyDetailResponse.self, from: data).energyDetails
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - powerFlow
    
    /// Will return the current power flow for the site
    /// - Parameters:
    ///   - siteId: The id of the site for which the power flow is needed
    ///   - apiKey: The api key to access the API
    /// - Returns: The current power flow
    static func powerFlow(for siteId: Int, apiKey: String) async throws -> SEMPowerFlow {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/currentPowerFlow"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct PowerFlowResponst: Codable {
            let siteCurrentPowerFlow: SEMPowerFlow
        }
        
        do {
            return try JSONDecoder().decode(PowerFlowResponst.self, from: data).siteCurrentPowerFlow
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - siteImage
    
    /// Will return the image data of the image for the site, if there is an image
    /// - Parameters:
    ///   - siteId: The id of the site for which the image is needed
    ///   - name: The name the image should have
    ///   - maxWidth: The max with the image should have
    ///   - maxHeight: The max height the image should have
    ///   - hash: The image hash. If provided, it will only download a new image. If not provided, the image will be diwnloaded if available. Parameter will be ignored by server, if `maxWidth` or `maxHeight` is used
    ///   - apiKey: The api key to access the API
    /// - Returns: The data of the image of the site, if there is one. If no image was saved, it will return `nil`.
    static func siteImage(for siteId: Int, name: String? = nil, maxWidth: Int? = nil, maxHeight: Int? = nil, hash: Int? = nil, apiKey: String) async throws -> Data? {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/siteImage/\(name ?? "image.jpg")"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        if let maxWidth {
            components.queryItems?.append(URLQueryItem(name: "maxWidth", value: "\(maxWidth)"))
        }
        if let maxHeight {
            components.queryItems?.append(URLQueryItem(name: "maxHeight", value: "\(maxHeight)"))
        }
        if let hash {
            components.queryItems?.append(URLQueryItem(name: "hash", value: "\(hash)"))
        }
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        do {
            try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        } catch {
            if let error = error as? SolarEdgeAPIError {
                switch error {
                case .notFound:
                    /// Not founc only happens if there is no image for the site.
                    return nil
                case .unmodified:
                    /// Image did not change since last request. So no need to send data again
                    return nil
                default:
                    throw error
                }
            } else {
                throw error
            }
        }
        
        return data
    }
    
    
    // MARK: - environmentalBenefits
    
    /// Will return the environmental benefits based on the site energy production
    /// - Parameters:
    ///   - siteId: The id of the site for which the image is needed
    ///   - systemUnit: The system unit which should be used
    ///   - apiKey: The api key to access the API
    /// - Returns: The environmental benefits
    static func environmentalBenefits(for siteId: Int, systemUnit: SystemUnit = .metric, apiKey: String) async throws -> SEEnvironmentalBenefits {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/envBenefits"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "systemUnit", value: systemUnit.rawValue)
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct SEEnvironmentalBenefitsResponse: Codable {
            let envBenefits: SEEnvironmentalBenefits
        }
        
        do {
            return try JSONDecoder().decode(SEEnvironmentalBenefitsResponse.self, from: data).envBenefits
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - installerImage
    
    /// Will return the image data of the installer, if there is an image
    /// - Parameters:
    ///   - siteId: The id of the site for which the image is needed
    ///   - name: The name the image should have
    ///   - apiKey: The api key to access the API
    /// - Returns: The data of the image of the site, if there is one. If no image was saved, it will return `nil`.
    static func installerImage(for siteId: Int, name: String? = nil, apiKey: String) async throws -> Data? {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/installerImage/\(name ?? "image.jpg")"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        do {
            try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        } catch {
            if let error = error as? SolarEdgeAPIError {
                switch error {
                case .notFound:
                    /// Not founc only happens if there is no image for the site.
                    return nil
                case .unmodified:
                    /// Image did not change since last request. So no need to send data again
                    return nil
                default:
                    throw error
                }
            } else {
                throw error
            }
        }
        
        return data
    }
    
    
    // MARK: - components
    
    /// Will return a list of components the site uses
    /// - Parameters:
    ///   - siteId: The id of the site for which the components are needed
    ///   - apiKey: The api key to access the API
    /// - Returns: The list of components the site uses
    static func components(for siteId: Int, apiKey: String) async throws -> [SEMComponent] {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/equipment/\(siteId)/list"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct ComponentsResponse: Codable {
            let reporters: ComponentsListResponse
        }
        
        struct ComponentsListResponse: Codable {
            let count: Int
            let list: [SEMComponent]
        }
        
        do {
            return try JSONDecoder().decode(ComponentsResponse.self, from: data).reporters.list
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - inventory
    
    /// Will return the inventory of a site
    /// - Parameters:
    ///   - siteId: The id of the site for which the inventory is needed
    ///   - apiKey: The api key to access the API
    /// - Returns: The inventory of a site
    static func inventory(for siteId: Int, apiKey: String) async throws -> SEMInventory {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/inventory"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct InventoryResponse: Codable {
            let Inventory: SEMInventory
        }
        
        do {
            return try JSONDecoder().decode(InventoryResponse.self, from: data).Inventory
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - inverterTechnicalData
    
    /// Will return all the technical data for a specific inverter for the given timeframe.
    /// The timeframe is limited to one week. Server will return an error if the timeframe is longer
    /// - Parameters:
    ///   - siteId: The id of the site for which the inverter technical data is needed
    ///   - serialNumber: The serial number of the inverter for which the technical data is needed
    ///   - startTime: The start time to get the technical data for
    ///   - endTime: The end time to get the technical data for
    ///   - apiKey: The api key to access the API
    /// - Returns: All the available technical data for the given inverter and time frame
    static func inverterTechnicalData(for siteId: Int, serialNumber: String, startTime: Date, endTime: Date, apiKey: String) async throws -> [String: Any] {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/equipment/\(siteId)/\(serialNumber)/data"
        components.queryItems = [
            URLQueryItem(name: "startTime", value: DateFormatter.apiDateTime.string(from: startTime)),
            URLQueryItem(name: "endTime", value: DateFormatter.apiDateTime.string(from: endTime)),
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        do {
            return try JSONSerialization.jsonObject(with: data) as! [String: Any]
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - metersLifetimeData
    
    /// Will return the lifetime energy reading for each meter connected
    /// - Parameters:
    ///   - siteId: The site for which the meters data is needed
    ///   - startTime: The power measurement start time
    ///   - endTime: The power measurement end time
    ///   - timeUnit: The aggregation type
    ///   - meterTypes: Optional a set of types for which data is wanted. If nil or empty, all meter types will be used
    ///   - apiKey: The api key to access the API
    /// - Returns: The lifetime energy reading of the meters
    static func metersLifetimeData(for siteId: Int, startTime: Date, endTime: Date, timeUnit: TimeUnit = .day, meterTypes: Set<SEMMeterData.MeterType>? = nil, apiKey: String) async throws -> SEMMetersData {
        var components = URLComponents(string: monitoringBaseURL)!
        components.path = "/site/\(siteId)/meters"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "startTime", value: DateFormatter.apiDateTime.string(from: startTime)),
            URLQueryItem(name: "endTime", value: DateFormatter.apiDateTime.string(from: endTime)),
            URLQueryItem(name: "timeUnit", value: timeUnit.rawValue)
        ]
        if let meterTypes, !meterTypes.isEmpty {
            components.queryItems?.append(URLQueryItem(name: "meters", value: meterTypes.map { $0.rawValue }.joined(separator: ",")))
        }
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        var request = URLRequest(url: url)
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct MeterDataResponse: Codable {
            let meterEnergyDetails: SEMMetersData
        }
        
        do {
            return try JSONDecoder().decode(MeterDataResponse.self, from: data).meterEnergyDetails
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
}
