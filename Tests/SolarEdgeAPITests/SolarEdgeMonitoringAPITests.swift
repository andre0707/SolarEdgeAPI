import XCTest
@testable import SolarEdgeAPI

final class SolarEdgeMonitoringAPITests: XCTestCase {
    
    fileprivate let apiKey: String = ""
    fileprivate let siteId: Int = 0
    fileprivate let inverterSerialNumber: String = ""
    
    // MARK: - SolarEdgeMonitoringAPI
    
    func test_accessingSites() async throws {
        let sites = try await SolarEdgeMonitoringAPI.sites(apiKey: apiKey)
        
        XCTAssert(sites.count == 1, "There sould be just one site for this api key")
        
        let site = sites.first!
        
        XCTAssert(site.id == siteId, "Site id does not match")
    }
    
    func test_accessingSiteDetails() async throws {
        let site = try await SolarEdgeMonitoringAPI.siteDetail(for: siteId, apiKey: apiKey)
        
        XCTAssert(site.id == siteId, "Site id does not match")
    }
    
    func test_accessingSiteData() async throws {
        let site = try await SolarEdgeMonitoringAPI.siteData(for: siteId, apiKey: apiKey)
        
        XCTAssert(site.startDate != nil, "Start date is not available")
        XCTAssert(site.endDate != nil, "End date is not available")
    }
    
    func test_accessingEnergy() async throws {
        let energy = try await SolarEdgeMonitoringAPI.energy(for: siteId, using: EnergyRequestParameter(startDate: Date.startOfToday, endDate: Date.endOfToday, timeUnit: .hour), apiKey: apiKey)
        
        print(energy)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingTotalEnergy() async throws {
        let endDate = Calendar.current.date(byAdding: DateComponents(day: 1), to: Date.startOfToday)!
        let totalEnergy = try await SolarEdgeMonitoringAPI.totalEnergy(for: siteId, startDate: Date.startOfThisYear, endDate: endDate, apiKey: apiKey)
        
        print(totalEnergy)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingPower() async throws {
        let power = try await SolarEdgeMonitoringAPI.power(for: siteId, startTime: Date.startOfToday, endTime: Date.endOfToday, apiKey: apiKey)
        
        print(power)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingOverview() async throws {
        let overview = try await SolarEdgeMonitoringAPI.overview(for: siteId, apiKey: apiKey)
        
        print(overview)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingPowerDetails() async throws {
        let detailedPower = try await SolarEdgeMonitoringAPI.detailedPower(for: siteId, from: Date.startOfToday, until: Date.endOfToday, apiKey: apiKey)
        
        print(detailedPower)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingEnergyDetails() async throws {
        let detailedEnergy = try await SolarEdgeMonitoringAPI.detailedEnergy(for: siteId, from: Date.startOfToday, until: Date.endOfToday, apiKey: apiKey)
        
        print(detailedEnergy)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingPowerFlow() async throws {
        let powerFlow = try await SolarEdgeMonitoringAPI.powerFlow(for: siteId, apiKey: apiKey)
        
        print(powerFlow)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingSiteImage() async throws {
        if let imageData = try await SolarEdgeMonitoringAPI.siteImage(for: siteId, apiKey: apiKey) {
            print(imageData)
            return
        }
        XCTAssert(false)
    }
    
    func test_accessingEnvironmentalBenefits() async throws {
        let environmentalBenefits = try await SolarEdgeMonitoringAPI.environmentalBenefits(for: siteId, apiKey: apiKey)
        
        print(environmentalBenefits)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingInstallerImage() async throws {
        if let imageData = try await SolarEdgeMonitoringAPI.installerImage(for: siteId, apiKey: apiKey) {
            print(imageData)
            return
        }
        XCTAssert(false)
    }
    
    func test_accessingComponents() async throws {
        let components = try await SolarEdgeMonitoringAPI.components(for: siteId, apiKey: apiKey)
        
        print(components)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingInventory() async throws {
        let inventory = try await SolarEdgeMonitoringAPI.inventory(for: siteId, apiKey: apiKey)
        
        print(inventory)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    func test_accessingTechnicalData() async throws {
        
        let startTime = Calendar.current.date(byAdding: DateComponents(day: -3), to: Date.startOfToday)! // Date.startOfToday
        let endTime = Date.endOfToday
        
        let inventory = try await SolarEdgeMonitoringAPI.inverterTechnicalData(for: siteId, serialNumber: inverterSerialNumber, startTime: startTime, endTime: endTime, apiKey: apiKey)
        
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
        let metersData = try await SolarEdgeMonitoringAPI.metersLifetimeData(for: siteId, startTime: Date.startOfThisMonth, endTime: endTime, timeUnit: .week, apiKey: apiKey)
        
        print(metersData)
        
        //XCTAssert(site.startDate != nil, "Start date is not available")
    }
    
    
    func test_dataReading() async throws {
        let (_minimumDate, _maximumDate) = try await SolarEdgeMonitoringAPI.siteData(for: siteId, apiKey: apiKey)
        guard let minimumDate = _minimumDate,
              let maximumDate = _maximumDate
        else { return }
        
        
        var data = [Int : [Double]]()
        for month in 1 ... 12 {
            for day in 1 ... 31 {
                let dateComponents = DateComponents(year: 2023, month: month, day: day, hour: 0, minute: 0, second: 0)
                guard let startDate = Calendar.current.date(from: dateComponents),
                      startDate >= minimumDate,
                      startDate <= maximumDate,
                      let endDate = Calendar.current.date(byAdding: DateComponents(day: 1), to: startDate)
                else { continue }
                
                
                let energy = try await SolarEdgeMonitoringAPI.totalEnergy(for: siteId, startDate: startDate, endDate: endDate, apiKey: apiKey)
                data[day, default: []].append(energy.energy)
            }
        }
        
        print(data)
    }
    
    func test_total() async throws {
        
        for month in 4 ... 9 {
            let dateComponents = DateComponents(year: 2023, month: month, day: 1, hour: 0, minute: 0, second: 0)
            guard let startDate = Calendar.current.date(from: dateComponents) else { continue }
            let endDate = startDate.endOfTheMonth
            
            let totalEnergy = try await SolarEdgeMonitoringAPI.totalEnergy(for: siteId, startDate: startDate, endDate: endDate, apiKey: apiKey)
            print("month \(month): \(totalEnergy.energy)")
        }
    }
}
