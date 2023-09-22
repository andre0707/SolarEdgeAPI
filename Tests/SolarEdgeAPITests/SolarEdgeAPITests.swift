import XCTest
@testable import SolarEdgeAPI

final class SolarEdgeAPITests: XCTestCase {
    
    fileprivate let username: String = ""
    fileprivate let password: String = ""
    fileprivate let siteId: Int = 0
    fileprivate let inverterSerialNumber: String = ""
    fileprivate let numberOfInstalledModulesForSite: Int = 0
    fileprivate let numberOfModuleGroupsForSite: Int = 0
    
    fileprivate let csrfToken: String = ""
    fileprivate let cookie: String = ""
    
    
    func test_login() async throws {
        /// Get the login data
        let loginData = try await SolarEdgeAPI.login(with: username, password: password)
        XCTAssertFalse(loginData.cookie.isEmpty)
        
        /// Use the just retrieved cookie string to send another requst
        let latestPowerFlow = try await SolarEdgeAPI.latestPowerflow(for: siteId, using: csrfToken, cookie: loginData.cookie)
        XCTAssertEqual(latestPowerFlow.updateRefreshRate, 3)
        XCTAssertEqual(latestPowerFlow.isPowerExported, !latestPowerFlow.isPowerImported)
    }
    
    func test_enviromentalBenefits() async throws {
        let environmentalBenefits = try await SolarEdgeAPI.environmentalBenefits(for: siteId, using: csrfToken, cookie: cookie)
        
        XCTAssertEqual(environmentalBenefits.gasEmissionSaved.units, "kg")
    }
    
    func test_weather() async throws {
        let weather = try await SolarEdgeAPI.weather(for: siteId, using: csrfToken, cookie: cookie)
        
        XCTAssertEqual(weather.systemUnit.lowercased(), "metric")
        XCTAssertEqual(weather.weatherForecasts.count, 4)
    }
    
    func test_layoutEnergy() async throws {
        let energyDay = try await SolarEdgeAPI.layoutEnergy(for: siteId, and: .day, using: csrfToken, cookie: cookie)
        XCTAssertEqual(energyDay.count, 34)
        
        let energyWeek = try await SolarEdgeAPI.layoutEnergy(for: siteId, and: .week, using: csrfToken, cookie: cookie)
        XCTAssertEqual(energyWeek.count, 34)
        
        let energyMonth = try await SolarEdgeAPI.layoutEnergy(for: siteId, and: .month, using: csrfToken, cookie: cookie)
        XCTAssertEqual(energyMonth.count, 34)
        
        let energyYear = try await SolarEdgeAPI.layoutEnergy(for: siteId, and: .year, using: csrfToken, cookie: cookie)
        XCTAssertEqual(energyYear.count, 34)
    }
    
    func test_physicalLayout() async throws {
        let layout = try await SolarEdgeAPI.physicalLayout(for: siteId, using: csrfToken, cookie: cookie)
        XCTAssertEqual(layout.groups.count, 3)
        
        let moduleIds = layout.groupIds.flatMap { $0 }
           
        XCTAssertEqual(moduleIds.count, 31)
    }
    
    func test_logicalLayout() async throws {
        let layout = try await SolarEdgeAPI.logicalLayout(for: siteId, and: .day, using: csrfToken, cookie: cookie)
        
        let inverter = layout.logicalTree.children.first
        XCTAssertNotNil(inverter)
        let moduleString = inverter!.children.first
        XCTAssertNotNil(moduleString)
        
        XCTAssertEqual(moduleString!.children.count, numberOfInstalledModulesForSite)
    }
    
    func test_checkGroupEnergy() async throws {
        /// The physical layout contains information about the groups
        let physicalLayout = try await SolarEdgeAPI.physicalLayout(for: siteId, using: csrfToken, cookie: cookie)
        /// The energy of each module
        let layoutEnergy = try await SolarEdgeAPI.layoutEnergy(for: siteId, and: .day, using: csrfToken, cookie: cookie)
        /// Lookup the energy for the ids and put it in groups
        let groupsEnergy = physicalLayout.groupIds.map { $0.compactMap { layoutEnergy["\($0)"] } }
        
        XCTAssertEqual(groupsEnergy.count, numberOfModuleGroupsForSite)
        
        /// Check if the group sizes are still the same and not empty
        XCTAssertEqual(groupsEnergy.count, physicalLayout.groupIds.count)
        for (index, groupEnergy) in groupsEnergy.enumerated() {
            XCTAssertEqual(groupEnergy.count, physicalLayout.groupIds[index].count)
            XCTAssertGreaterThan(groupEnergy.count, 0)
        }
        
        for groupEnergy in groupsEnergy {
            let maximumEnergy = groupEnergy.max(by: { $0.unscaledEnergy ?? 1 < $1.unscaledEnergy ?? 1 })?.unscaledEnergy ?? 1
            let minimumEnergy = groupEnergy.min(by: { $0.unscaledEnergy ?? 1 < $1.unscaledEnergy ?? 1 })?.unscaledEnergy ?? 1
            
            print("Group with \(groupEnergy.count) modules:")
            print("Ratio min/max: \(minimumEnergy)/\(maximumEnergy) = \(String(format: "%.2f", minimumEnergy/maximumEnergy * 100))%")
            XCTAssertGreaterThan(minimumEnergy/maximumEnergy, 0.80)
        }
    }
    
    func test_dataAvailability() async throws {
        let (startDate, endDate) = try await SolarEdgeAPI.dataAvailability(for: siteId, using: csrfToken, cookie: cookie)
        
        XCTAssertGreaterThan(endDate, startDate)
    }
    
    func test_energyCompare() async throws {
        let energyCompare = try await SolarEdgeAPI.energyCompare(for: siteId, using: csrfToken, cookie: cookie)
        
        XCTAssertEqual(energyCompare.month.xAxis.count, 12)
        XCTAssertEqual(energyCompare.quarter.xAxis.count, 4)
    }
    
    func test_energyOverview() async throws {
        let energyOverview = try await SolarEdgeAPI.energyOverview(for: siteId, using: csrfToken, cookie: cookie)
        
        XCTAssertEqual(energyOverview.count, 4)
    }
    
    func test_energyMeasurements() async throws {
        let energyMeasurements = try await SolarEdgeAPI.energyMeasurements(for: siteId, timePeriod: .day, endDate: Date.now, using: csrfToken, cookie: cookie)
        
        XCTAssertEqual(energyMeasurements.measurements.count, 96)
    }
    
    func test_latestPowerflow() async throws {
        let latestPowerFlow = try await SolarEdgeAPI.latestPowerflow(for: siteId, using: csrfToken, cookie: cookie)
        
        XCTAssertEqual(latestPowerFlow.updateRefreshRate, 3)
        XCTAssertEqual(latestPowerFlow.isPowerExported, !latestPowerFlow.isPowerImported)
    }
}
