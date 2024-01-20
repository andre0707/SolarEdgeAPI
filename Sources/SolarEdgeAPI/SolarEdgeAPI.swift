//
//  SolarEdgeAPI.swift
//  
//
//  Created by Andre Albach on 03.08.23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The user agent which is used
fileprivate let userAgent = "SolarEdge/5 CFNetwork/1410.0.3 Darwin/22.6.0"

/// Private extension for the http methode
fileprivate extension URLRequest {
    enum HTTPMethod: String, Equatable {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
    }
    
    enum ContentType: String {
        case json = "application/json"
        case urlEncoded = "application/x-www-form-urlencoded"
    }
}


/// Namespace for all the API functions
public enum SolarEdgeAPI {
    
    /// The base url address for api calls
    static private var baseURL: String { "https://\(baseDomain)" }
    /// The base domain address for api calls
    static private let baseDomain = "api.solaredge.com"
    
    /// This function will create the urlRequest
    /// It will always set: User-Agent, Host, Accept, Connection, Accept-Encoding, Content-Type
    /// - Parameters:
    ///   - url: The URL for the request
    ///   - userAgent: The user agent to use
    ///   - cookie: The access cookie
    ///   - httpMethode: The http methode to use
    /// - Returns: The resulting URL request
    private static func urlRequest(url: URL,
                                   userAgent: String,
                                   contentType: URLRequest.ContentType? = .json,
                                   cookie: String? = nil,
                                   csrfToken: String? = nil,
                                   httpMethode: URLRequest.HTTPMethod = .get) -> URLRequest {
        
        var request = URLRequest(url: url)
        if let contentType = contentType {
            request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        request.addValue("3.12", forHTTPHeaderField: "CLIENT-VERSION")
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        if let cookie = cookie {
            request.addValue(cookie, forHTTPHeaderField: "Cookie")
        }
        
        if let csrfToken = csrfToken {
            request.addValue(csrfToken, forHTTPHeaderField: "x-csrf-token")
        }
        
        if httpMethode == .post || httpMethode == .put {
            request.httpMethod = httpMethode.rawValue
        }
        
        return request
    }
    
    /// This function will create the urlRequest
    /// It will always set: User-Agent, Host, Accept, Connection, Accept-Encoding, Content-Type
    /// - Parameters:
    ///   - url: The URL for the request
    ///   - userAgent: The user agent to use
    ///   - cookie: The access cookie
    ///   - httpMethode: The http methode to use
    ///   - body: The body which should be added. This Dictionary will be transformed to a JSON string
    /// - Returns: The resulting URL request
    private static func urlRequest(url: URL,
                                   userAgent: String,
                                   contentType: URLRequest.ContentType? = .json,
                                   cookie: String? = nil,
                                   csrfToken: String? = nil,
                                   httpMethode: URLRequest.HTTPMethod = .get,
                                   body: [String: Any]? = nil) throws -> URLRequest {
        
        var request = urlRequest(url: url, userAgent: userAgent, contentType: contentType, cookie: cookie, csrfToken: csrfToken, httpMethode: httpMethode)
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        return request
    }
    
    private static func urlRequest(url: URL,
                                   userAgent: String,
                                   contentType: URLRequest.ContentType? = .json,
                                   cookie: String? = nil,
                                   csrfToken: String? = nil,
                                   httpMethode: URLRequest.HTTPMethod = .get,
                                   body: Data? = nil) throws -> URLRequest {
        
        var request = urlRequest(url: url, userAgent: userAgent, contentType: contentType, cookie: cookie, csrfToken: csrfToken, httpMethode: httpMethode)
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
}


// MARK: - Async Functions

public extension SolarEdgeAPI {
    
    // MARK: - login
    
    /// Will login the user with `username` and `password` and return the login cookie which is needed for all further calls
    /// - Parameters:
    ///   - username: The username for the login
    ///   - password: The password matching the username for the login
    /// - Returns: The cookie string which is needed for all further api calls
    static func login(with username: String, password: String) async throws -> SELoginData {
        var components = URLComponents(string: baseURL)!
        components.path = "/solaredge-apigw/api/login"
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        let bodyString = "j_username=\(username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)&j_password=\(password.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)"
        let bodyData = bodyString.data(using: .utf8)
        
        let request = try urlRequest(url: url, userAgent: userAgent, contentType: .urlEncoded, httpMethode: .post, body: bodyData)
        
        let (data, urlResponse) = try await URLSession.shared.asyncData(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        guard let userDataInXml = String(data: data, encoding: .utf8) else { throw SolarEdgeAPIError.response }
        
        guard let cookies = URLSession.shared.configuration.httpCookieStorage?.cookies?.filter({ $0.domain == baseDomain }),
              !cookies.isEmpty
        else { throw SolarEdgeAPIError.describingError("Error with cookies") }
        
        let cookieString = cookies
            .map { "\($0.name)=\($0.value)" }
            .joined(separator: "; ")
        
        return SELoginData(cookie: cookieString, xmlUserData: userDataInXml)
    }
    
    
    // MARK: - environmentalBenefits
    
    /// Will return the environmental benefits based on the site energy production
    /// - Parameters:
    ///   - siteId: The id of the site for which the environmental benefits are needed
    ///   - csrfToken: The csrfToken to use
    ///   - cookie: The cookie to access the API
    /// - Returns: The environmental benefits
    static func environmentalBenefits(for siteId: Int, using csrfToken: String, cookie: String) async throws -> SEEnvironmentalBenefits {
        var components = URLComponents(string: baseURL)!
        components.path = "/solaredge-apigw/api/site/\(siteId)/envBenefits.json"
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        let request = urlRequest(url: url, userAgent: userAgent, cookie: cookie,  csrfToken: csrfToken)
        
        let (data, urlResponse) = try await URLSession.shared.asyncData(for: request, delegate: nil)
        
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
    
    
    // MARK: - weather
    
    /// Will return the weather for the site
    /// - Parameters:
    ///   - siteId: The id of the site for which the weather is needed
    ///   - csrfToken: The csrfToken to use
    ///   - cookie: The cookie to access the API
    /// - Returns: The weather data. Including live and forcast data
    static func weather(for siteId: Int, using csrfToken: String, cookie: String) async throws -> SEWeather {
        var components = URLComponents(string: baseURL)!
        components.path = "/services/weather/getWeatherWidget"
        components.queryItems = [
            URLQueryItem(name: "siteId", value: "\(siteId)")
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        let request = urlRequest(url: url, userAgent: userAgent, cookie: cookie, csrfToken: csrfToken)
        
        let (data, urlResponse) = try await URLSession.shared.asyncData(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        do {
            return try JSONDecoder().decode(SEWeather.self, from: data)
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - dataAvailability
    
    /// Will return the time range in which data is available for the site with the passed in `siteID`.
    /// - Parameters:
    ///   - siteId: The id of the site for which the data availability is needed
    ///   - csrfToken: The csrfToken to use
    ///   - cookie: The cookie to access the API
    /// - Returns: The start and end dates in which data is available
    static func dataAvailability(for siteId: Int, using csrfToken: String, cookie: String) async throws -> (startDate: Date, endDate: Date) {
        var components = URLComponents(string: baseURL)!
        components.path = "/services/so/dashboard/site/\(siteId)/dataAvailability"
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        let request = urlRequest(url: url, userAgent: userAgent, cookie: cookie, csrfToken: csrfToken)
        
        let (data, urlResponse) = try await URLSession.shared.asyncData(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct DateAvailabilityResponse: Codable {
            let startDate: Date
            let endDate: Date
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                let _startDate = try container.decode(String.self, forKey: .startDate)
                if let startDate = DateFormatter.apiDateTimeTimezone.date(from: _startDate) {
                    self.startDate = startDate
                } else {
                    throw SolarEdgeAPIError.decoding("Invalid date")
                }
                let _endDate = try container.decode(String.self, forKey: .endDate)
                if let endDate = DateFormatter.apiDateTimeTimezone.date(from: _endDate) {
                    self.endDate = endDate
                } else {
                    throw SolarEdgeAPIError.decoding("Invalid date")
                }
            }
        }
        
        do {
            let dateAvailabilityResponse = try JSONDecoder().decode(DateAvailabilityResponse.self, from: data)
            return (dateAvailabilityResponse.startDate, dateAvailabilityResponse.endDate)
            
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - energyCompare
    
    /// Will return the energy compare data. This includes accumulated data for months, quarters and years.
    /// This is best used when data is presented in charts or overviews.
    ///
    /// (In the official app, these are used for the production compare bar chart)
    /// - Parameters:
    ///   - siteId: The id of the site for which the layout energy is needed
    ///   - csrfToken: The csrfToken to use
    ///   - cookie: The cookie to access the API
    /// - Returns: The energy compare information accumulated for certain time spans
    static func energyCompare(for siteId: Int, using csrfToken: String, cookie: String) async throws -> SEEnergyCompare {
        var components = URLComponents(string: baseURL)!
        components.path = "/solaredge-apigw/api/site/\(siteId)/energyCompare.json"
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        let request = urlRequest(url: url, userAgent: userAgent, cookie: cookie, csrfToken: csrfToken)
        
        let (data, urlResponse) = try await URLSession.shared.asyncData(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        do {
            guard let jsonObject = (try JSONSerialization.jsonObject(with: data) as? [String : Any])?["energyCompare"] as? [String : Any],
                  var month = jsonObject["month"] as? [String : Any],
                  var quarter = jsonObject["quarter"] as? [String : Any],
                  var year = jsonObject["year"] as? [String : Any]
            else { throw SolarEdgeAPIError.decoding("Error with data from energyCompare") }
            
            guard let monthXAxis = month.removeValue(forKey: "xAxis") as? [String],
                  let monthValues = month as? [String : [String : Int]]
            else { throw SolarEdgeAPIError.decoding("Error with data from energyCompare in month") }
            
            guard let quarterXAxis = quarter.removeValue(forKey: "xAxis") as? [String],
                  let quarterValues = quarter as? [String : [String : Int]]
            else { throw SolarEdgeAPIError.decoding("Error with data from energyCompare in quarter") }
            
            guard let yearXAxis = year.removeValue(forKey: "xAxis") as? [String],
                  let yearValues = year as? [String : [String : Int]]
            else { throw SolarEdgeAPIError.decoding("Error with data from energyCompare in year") }
            
            return SEEnergyCompare(month: SEEnergyCompare.SEEnergyData(xAxis: monthXAxis, values: monthValues),
                                 quarter: SEEnergyCompare.SEEnergyData(xAxis: quarterXAxis, values: quarterValues),
                                 year: SEEnergyCompare.SEEnergyData(xAxis: yearXAxis, values: yearValues))
            
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - energyOverview
    
    /// Will return a list of energy overviews. The list should include the overview for all time periods (see EnergyOverview.TimePeriod)
    ///
    /// (In the official app, these are the values for the produced energy: today, this month, this year, total)
    /// - Parameters:
    ///   - siteId: The id of the site for which the layout energy is needed
    ///   - csrfToken: The csrfToken to use
    ///   - cookie: The cookie to access the API
    /// - Returns: The energy overview information
    static func energyOverview(for siteId: Int, using csrfToken: String, cookie: String) async throws -> [SEEnergyOverview] {
        var components = URLComponents(string: baseURL)!
        components.path = "/services/m/so/dashboard/site/\(siteId)/energyOverview"
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        let request = urlRequest(url: url, userAgent: userAgent, cookie: cookie, csrfToken: csrfToken)
        
        let (data, urlResponse) = try await URLSession.shared.asyncData(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        struct SEEnergyOverviewResponse: Codable {
            let energyProducedOverviewList: [SEEnergyOverview]
        }
        
        do {
            return try JSONDecoder().decode(SEEnergyOverviewResponse.self, from: data).energyProducedOverviewList
            
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - energyMeasurements
    
    /// Will return a detail list of energy measurements.
    ///
    /// (In the official app, these are the values used to create the main chart(s) which holds infos about production and consumption)
    /// - Parameters:
    ///   - siteId: The id of the site for which the layout energy is needed
    ///   - csrfToken: The csrfToken to use
    ///   - cookie: The cookie to access the API
    ///   - timePeriod: The time period for which the measurement data is needed.
    ///   - endDate: The date (if `timePeriod` is `.day`) or end date until when the energy measurement is needed
    /// - Returns: The energy measurements for the specified `timePeriod` and `endDate`
    static func energyMeasurements(for siteId: Int, timePeriod: SEMeasurement.SETimePeriod, endDate: Date, using csrfToken: String, cookie: String) async throws -> SEMeasurement {
        var components = URLComponents(string: baseURL)!
        components.path = "/services/m/so/dashboard/site/\(siteId)/measurements"
        
        components.queryItems = [
            URLQueryItem(name: "period", value: timePeriod.rawValue),
            URLQueryItem(name: "end-date", value: DateFormatter.apiDate.string(from: endDate)),
            URLQueryItem(name: "measurement-unit", value: timePeriod == .day ? "WATT" : "WATT_HOUR")
        ]
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        let request = urlRequest(url: url, userAgent: userAgent, cookie: cookie, csrfToken: csrfToken)
        
        let (data, urlResponse) = try await URLSession.shared.asyncData(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        do {
            return try JSONDecoder().decode(SEMeasurement.self, from: data)
            
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - latestPowerflow
    
    /// Will return the latest power flow. This can usually be updated up to every 3 seconds
    /// - Parameters:
    ///   - siteId: The id of the site for which the latest power flow is needed
    ///   - csrfToken: The csrfToken to use
    ///   - cookie: The cookie to access the API
    /// - Returns: The latest power flow
    static func latestPowerflow(for siteId: Int, using csrfToken: String, cookie: String?) async throws -> SEPowerFlow {
        var components = URLComponents(string: baseURL)!
        components.path = "/services/m/so/dashboard/site/\(siteId)/powerflow/latest"
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        let request = urlRequest(url: url, userAgent: userAgent, cookie: cookie, csrfToken: csrfToken)
        
        let (data, urlResponse) = try await URLSession.shared.asyncData(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        do {
            return try JSONDecoder().decode(SEPowerFlow.self, from: data)
            
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - layoutEnergy
    
    /// Will return the energy by module of the layout
    /// - Parameters:
    ///   - siteId: The id of the site for which the layout energy is needed
    ///   - timeRange: The time unit
    ///   - csrfToken: The csrfToken to use
    ///   - cookie: The cookie to access the API
    /// - Returns: A dictionary which maps the layout energy to the module identifier
    static func layoutEnergy(for siteId: Int, and timeRange: SETimeRange?, using csrfToken: String, cookie: String) async throws -> [String : SELayoutEnergy] {
        var components = URLComponents(string: baseURL)!
        components.path = "/solaredge-apigw/api/sites/\(siteId)/layout/energy.json"
        if let timeRange {
            components.queryItems = [
                URLQueryItem(name: "timeUnit", value: timeRange.rawValue)
            ]
        }
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        let bodyData = [
            "reporterIds" : [1]
        ]
        
        let request = try urlRequest(url: url, userAgent: userAgent, cookie: cookie, csrfToken: csrfToken, httpMethode: .post, body: bodyData)
        
        let (data, urlResponse) = try await URLSession.shared.asyncData(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        do {
            return try JSONDecoder().decode([String : SELayoutEnergy].self, from: data)
            
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - physicalLayout
    
    /// Will return the physical layout
    /// - Parameters:
    ///   - siteId: The id of the site for which the layout energy is needed
    ///   - csrfToken: The csrfToken to use
    ///   - cookie: The cookie to access the API
    /// - Returns: The physical layout which contains information about the grouping
    static func physicalLayout(for siteId: Int, using csrfToken: String, cookie: String) async throws -> SEPhysicalLayout {
        var components = URLComponents(string: baseURL)!
        components.path = "/solaredge-apigw/api/sites/\(siteId)/layout/physical.json"
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        let request = urlRequest(url: url, userAgent: userAgent, cookie: cookie, csrfToken: csrfToken)
        
        let (data, urlResponse) = try await URLSession.shared.asyncData(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        do {
            return try JSONDecoder().decode(SEPhysicalLayout.self, from: data)
            
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
    
    
    // MARK: - logicalLayout
    
    /// Will return the logical layout
    /// - Parameters:
    ///   - siteId: The id of the site for which the layout energy is needed
    ///   - timeRange: The time unit
    ///   - csrfToken: The csrfToken to use
    ///   - cookie: The cookie to access the API
    /// - Returns: The logical layout
    static func logicalLayout(for siteId: Int, and timeRange: SETimeRange?, using csrfToken: String, cookie: String) async throws -> SELogicalLayout {
        var components = URLComponents(string: baseURL)!
        components.path = "/solaredge-apigw/api/sites/\(siteId)/layout/logical.json"
        
        guard let url = components.url else { throw SolarEdgeAPIError.badURL }
        
        let request = urlRequest(url: url, userAgent: userAgent, cookie: cookie, csrfToken: csrfToken)
        
        let (data, urlResponse) = try await URLSession.shared.asyncData(for: request, delegate: nil)
        
        guard let response = urlResponse as? HTTPURLResponse else { throw SolarEdgeAPIError.response }
        
        try SolarEdgeAPIError.checkResponseWith(data: data, response: response)
        
        do {
            return try JSONDecoder().decode(SELogicalLayout.self, from: data)
            
        } catch {
            throw SolarEdgeAPIError.decoding(error.localizedDescription)
        }
    }
}
