# SolarEdgeAPI

This is a `Swift` API wrapper for the *SolarEdge* monitoring API and the *SolarEdge* API.
The monitoring API is the official provided API by *SolarEdge*, while their own app uses a different API.
While there is documentation for the monitoring API, the API used by the official *SolarEdge* app seems to be undocumented.

This package provides acces to both APIs.

Both API wrappers are heavily based on the `Codable` protocol and provides `structs` for each type for easier access.
The variable names in all structs are mostly the names as used in the APIs.


## Package Versioning

With version 2.0.0 of this package, there was a big re-design when adding support for the API the offical *SolarEdge* app uses.
All structs have been renamed to better reflect which API they belong to.
The *SE* prefix stands for the SolarEdge API, while the *SEM* prefix stands for the SolarEdgeMonitoring API.


## Monitoring API

The monitporing API documentation can be found [here](https://knowledge-center.solaredge.com/sites/kc/files/se_monitoring_api.pdf).

The terms and conditions for API usage can be found [here](https://monitoring.solaredge.com/solaredge-web/p/license).


### API key

You need to create your own API key to access your data.
Check the above linked documentation for how to create one.


### How to use the monitoring API

All API functions are static methods on the `SolarEdgeMonitoringAPI` enum.

Start with reading your site and retrive the siteId. The siteId is then needed for all the other API calls 

```Swift
let apiKey: String = "YourAPIKey" //Check section `API Key` on how to get an API key
let sites = try await SolarEdgeMonitoringAPI.sites(apiKey: apiKey)
let siteId: Int = sites.first!.id
```

Reading the current power flow then works like this:

```Swift
let powerFlow = try await SolarEdgeMonitoringAPI.powerFlow(for: siteId, apiKey: apiKey)
print("PV currently produces \(powerFlow.pv.currentPower.formatted())\(powerFlow.unit)")
```

Print the produced energy from the day before:

```Swift
let startDate = Calendar.current.date(byAdding: DateComponents(day: -1), to: Date.startOfToday)!
let powerForLastDay = try await SolarEdgeMonitoringAPI.totalEnergy(for: siteId, startDate: startDate, endDate: Date.startOfToday, apiKey: apiKey)
print("There were \(powerForLastDay.description) produced on \(startDate.formatted(date: .numeric, time: .omitted)).")
```

Print the produced energy from the current month:

```Swift
let powerForThisMonth = try await SolarEdgeMonitoringAPI.totalEnergy(for: siteId, startDate: Date.startOfThisMonth, endDate: Date.endOfThisMonth, apiKey: apiKey)
print("There were \(powerForThisMonth.description) produced in the current month.")
```

Print the percentages of the energy balance

```Swift
let detailedEnergy = try await SolarEdgeMonitoringAPI.detailedEnergy(for: siteId, from: Date.startOfToday, until: Date.endOfToday, apiKey: apiKey)
let percentageString = """
Feed in: \(detailedEnergy.feedInPercentage ?? 0)%
Self usage: \(detailedEnergy.selfUsagePercentage ?? 0)%
Purchased: \(detailedEnergy.purchasedPercentage ?? 0)%
Self consumption: \(detailedEnergy.selfConsumptionPercentage ?? 0)%
"""
print(percentageString)
```

### Limitations

This Swift package currently does not support any *bulk api calls*. 
This means it is currently only for single site use.
*Bulk calls* might be added later.

------------------------------------------------------------------------------------------------------------


## SolarEdge API

This is the API the official *SolarEdge* app uses on iOS.
It has the advantage of providing more data (for example details for each optimizer), but is not the official documented API.

Instead of using the generated API key like the monitoring API, it is based on a login and then uses a csrf token and cookie.


### How to use the API

All API functions are static methods on the `SolarEdgeAPI` enum.

Start with logging in 

```Swift
let username = "myemail@example.com"
let password = "mysecretpassword"

let loginData = try SolarEdgeAPI.login(with: username, password: password)
```

Once you have the cookie stored in the `loginData`, you can use all other API functions.
For example getting the environmental benefits data, use the following API call:

```Swift
let environmentalBenefits = try await SolarEdgeAPI.environmentalBenefits(for: siteId, using: csrfToken, cookie: loginData.cookie)
```

If you want to get the time range in which data is actual available, use:

```Swift
let (startDate, endDate) = try await SolarEdgeAPI.dataAvailability(for: siteId, using: csrfToken, cookie: loginData.cookie)
```

------------------------------------------------------------------------------------------------------------

## Questions, bugs, new features, ...

Feel free to contact me or open an Issue or create a pull request.


## License

See attached LICENSE file.
