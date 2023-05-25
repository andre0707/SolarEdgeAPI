import XCTest
@testable import SolarEdgeAPI

final class SolarEdgeAPITests: XCTestCase {
    
    fileprivate let apiKey: String = ""
    fileprivate let siteId: Int = 0
    fileprivate let inverterSerialNumber: String = ""
    
    func test_accessingSites() async throws {
        let sites = try await SolarEdgeAPI.sites(apiKey: apiKey)
        
        XCTAssert(sites.count == 1, "There sould be just one site for this api key")
        
        let site = sites.first!
        
        XCTAssert(site.id == siteId, "Site id does not match")
    }
    
    func test_accessingSiteDetails() async throws {
        let site = try await SolarEdgeAPI.siteDetail(for: siteId, apiKey: apiKey)
        
        XCTAssert(site.id == siteId, "Site id does not match")
    }
    
    func test_accessingSiteData() async throws {
        let site = try await SolarEdgeAPI.siteData(for: siteId, apiKey: apiKey)
        
        XCTAssert(site.startDate != nil, "Start date is not available")
        XCTAssert(site.endDate != nil, "End date is not available")
    }
    
    func test_accessingEnergy() async throws {
        let energy = try await SolarEdgeAPI.energy(for: siteId, using: EnergyRequestParameter(startDate: Date.startOfToday, endDate: Date.endOfToday, timeUnit: .hour), apiKey: apiKey)
        
        print(energy)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingTotalEnergy() async throws {
        let endDate = Calendar.current.date(byAdding: DateComponents(day: 1), to: Date.startOfToday)!
        let totalEnergy = try await SolarEdgeAPI.totalEnergy(for: siteId, startDate: Date.startOfToday, endDate: endDate, apiKey: apiKey)
        
        print(totalEnergy)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingPower() async throws {
        let power = try await SolarEdgeAPI.power(for: siteId, startTime: Date.startOfToday, endTime: Date.endOfToday, apiKey: apiKey)
        
        print(power)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingOverview() async throws {
        let overview = try await SolarEdgeAPI.overview(for: siteId, apiKey: apiKey)
        
        print(overview)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingPowerDetails() async throws {
        let detailedPower = try await SolarEdgeAPI.detailedPower(for: siteId, from: Date.startOfToday, until: Date.endOfToday, apiKey: apiKey)
        
        print(detailedPower)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingEnergyDetails() async throws {
        let detailedEnergy = try await SolarEdgeAPI.detailedEnergy(for: siteId, from: Date.startOfToday, until: Date.endOfToday, apiKey: apiKey)
        
        print(detailedEnergy)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingPowerFlow() async throws {
        let powerFlow = try await SolarEdgeAPI.powerFlow(for: siteId, apiKey: apiKey)
        
        print(powerFlow)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingSiteImage() async throws {
        if let imageData = try await SolarEdgeAPI.siteImage(for: siteId, apiKey: apiKey) {
            print(imageData)
            return
        }
        XCTAssert(false)
    }
    
    func test_accessingEnvironmentalBenefits() async throws {
        let environmentalBenefits = try await SolarEdgeAPI.environmentalBenefits(for: siteId, apiKey: apiKey)
        
        print(environmentalBenefits)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingInstallerImage() async throws {
        if let imageData = try await SolarEdgeAPI.installerImage(for: siteId, apiKey: apiKey) {
            print(imageData)
            return
        }
        XCTAssert(false)
    }
    
    func test_accessingComponents() async throws {
        let components = try await SolarEdgeAPI.components(for: siteId, apiKey: apiKey)
        
        print(components)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingInventory() async throws {
        let inventory = try await SolarEdgeAPI.inventory(for: siteId, apiKey: apiKey)
        
        print(inventory)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingTechnicalData() async throws {
        
        let startTime = Calendar.current.date(byAdding: DateComponents(day: -3), to: Date.startOfToday)! // Date.startOfToday
        let endTime = Date.endOfToday
        
        let inventory = try await SolarEdgeAPI.inverterTechnicalData(for: siteId, serialNumber: inverterSerialNumber, startTime: startTime, endTime: endTime, apiKey: apiKey)
        
        let telemetries = (inventory["data"] as! [String: Any])["telemetries"] as! [[String: Any]]
        
        let maxTemperature = telemetries
            .compactMap { $0["temperature"] as? Double }
            .max()
        
        print("Max temperature: \(maxTemperature ?? 0)")
        
        print(inventory)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingMetersData() async throws {
        let endTime = Calendar.current.date(byAdding: DateComponents(day: 0), to: Date.endOfToday)!
        let metersData = try await SolarEdgeAPI.metersLifetimeData(for: siteId, startTime: Date.startOfThisMonth, endTime: endTime, timeUnit: .week, apiKey: apiKey)
        
        print(metersData)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
}
