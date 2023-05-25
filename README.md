# SolarEdgeAPI

This is a `Swift` API wrapper for the *SolarEdge* monitoring API.
It is based on the `Codable` protocol and provides `structs` for each type.
The variable names are names as in the API. 

The API documentation can be found [here](https://knowledge-center.solaredge.com/sites/kc/files/se_monitoring_api.pdf).

The terms and conditions for API usage can be found [here](https://monitoring.solaredge.com/solaredge-web/p/license).


## API key

You need to create your own API key to access your data.
Check the above linked documentation for how to create one.


## How to use this package

All API functions are static methods on the `SolarEdgeAPI` enum.

Start with reading your site and retrive the siteId. The siteId is then needed for all the other API calls 

```Swift
let apiKey: String = "YourAPIKey" //Check section `API Key` on how to get an API key
let sites = try await SolarEdgeAPI.sites(apiKey: apiKey)
let siteId: Int = sites.first!.id
```

Reading the current power flow then works like this:

```Swift
let powerFlow = try await SolarEdgeAPI.powerFlow(for: siteId, apiKey: apiKey)
print("PV currently produces \(powerFlow.pv.currentPower.formatted())\(powerFlow.unit)")
```

Print the produced energy from the day before:

```Swift
let startDate = Calendar.current.date(byAdding: DateComponents(day: -1), to: Date.startOfToday)!
let powerForLastDay = try await SolarEdgeAPI.totalEnergy(for: siteId, startDate: startDate, endDate: Date.startOfToday, apiKey: apiKey)
print("There were \(powerForLastDay.description) produced on \(startDate.formatted(date: .numeric, time: .omitted)).")
```

Print the produced energy from the current month:

```Swift
let powerForThisMonth = try await SolarEdgeAPI.totalEnergy(for: siteId, startDate: Date.startOfThisMonth, endDate: Date.endOfThisMonth, apiKey: apiKey)
print("There were \(powerForThisMonth.description) produced in the current month.")
```

Print the percentages of the energy balance

```Swift
let detailedEnergy = try await SolarEdgeAPI.detailedEnergy(for: siteId, from: Date.startOfToday, until: Date.endOfToday, apiKey: apiKey)
let percentageString = """
Feed in: \(detailedEnergy.feedInPercentage ?? 0)%
Self usage: \(detailedEnergy.selfUsagePercentage ?? 0)%
Purchased: \(detailedEnergy.purchasedPercentage ?? 0)%
Self consumption: \(detailedEnergy.selfConsumptionPercentage ?? 0)%
"""
print(percentageString)
```


## Limitations

This Swift package currently does not support any *bulk api calls*. 
This means it is currently only for single site use.
*Bulk calls* might be added later.
