//
//  SEWeather.swift
//
//
//  Created by Andre Albach on 31.08.23.
//

import Foundation

/// Weather data
public struct SEWeather: Codable {
    /// The current weather
    public let liveWeather: SELiveWeather
    /// Weather forcast for the next couple days
    public let weatherForecasts: [SEWeatherForecast]
    /// The sun time (rising and setting)
    public let sunTime: SESunTime
    /// The uni the data is in
    public let systemUnit: String
}


public extension SEWeather {
    /// Data about the current live weather
    struct SELiveWeather: Codable {
        public let latitude: Double
        public let longitude: Double
        public let weatherDate: Date
        public let humidity: Int
        public let currentTemperature: Double
        public let windSpeed: Double
        public let windDirection: String
        public let feelsLikeTemperature: Double
        public let currentCondition: String
//        public let snowDaily
//        public let snowRate
//        public let rainDaily
//        public let visibility
        
        /// The coding keys
        enum CodingKeys: String, CodingKey {
            case latitude
            case longitude
            case weatherDate
            case humidity
            case currentTemperature = "currentTemp"
            case windSpeed
            case windDirection
            case feelsLikeTemperature = "feelsLike"
            case currentCondition
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.latitude = try container.decode(Double.self, forKey: .latitude)
            self.longitude = try container.decode(Double.self, forKey: .longitude)
            let _weatherDate = try container.decode(String.self, forKey: .weatherDate)
            guard let weatherDate = DateFormatter.apiDateTimeTimezone.date(from: _weatherDate) else { throw SolarEdgeAPIError.decoding("Invalid date") }
            self.weatherDate = weatherDate
            self.humidity = try container.decode(Int.self, forKey: .humidity)
            self.currentTemperature = try container.decode(Double.self, forKey: .currentTemperature)
            self.windSpeed = try container.decode(Double.self, forKey: .windSpeed)
            self.windDirection = try container.decode(String.self, forKey: .windDirection)
            self.feelsLikeTemperature = try container.decode(Double.self, forKey: .feelsLikeTemperature)
            self.currentCondition = try container.decode(String.self, forKey: .currentCondition)
        }
    }
}


public extension SEWeather {
    /// The weather forcast for a single day
    struct SEWeatherForecast: Codable {
        public let latitude: Double
        public let longitude: Double
        public let weatherDate: Date
        public let temperatureHigh: Double
        public let temperatureLow: Double
        public let description: String
        
        /// The coding keys
        enum CodingKeys: String, CodingKey {
            case latitude
            case longitude
            case weatherDate
            case temperatureHigh = "tempHigh"
            case temperatureLow = "tempLow"
            case description
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.latitude = try container.decode(Double.self, forKey: .latitude)
            self.longitude = try container.decode(Double.self, forKey: .longitude)
            let _weatherDate = try container.decode(String.self, forKey: .weatherDate)
            guard let weatherDate = DateFormatter.apiDate.date(from: _weatherDate) else { throw SolarEdgeAPIError.decoding("Invalid date") }
            self.weatherDate = weatherDate
            self.temperatureHigh = try container.decode(Double.self, forKey: .temperatureHigh)
            self.temperatureLow = try container.decode(Double.self, forKey: .temperatureLow)
            self.description = try container.decode(String.self, forKey: .description)
        }
    }
}


public extension SEWeather {
    /// The weather forcast for a single day
    struct SESunTime: Codable {
        public let sunrise: Date
        public let sunset: Date
        
        /// The coding keys
        enum CodingKeys: String, CodingKey {
            case sunrise = "Sunrise"
            case sunset = "Sunset"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let _sunrise = try container.decode(String.self, forKey: .sunrise)
            guard let weatherDate = DateFormatter.apiDateTimeTimezone.date(from: _sunrise) else { throw SolarEdgeAPIError.decoding("Invalid date") }
            self.sunrise = weatherDate
            
            let _sunset = try container.decode(String.self, forKey: .sunset)
            guard let weatherDate = DateFormatter.apiDateTimeTimezone.date(from: _sunset) else { throw SolarEdgeAPIError.decoding("Invalid date") }
            self.sunset = weatherDate
        }
    }
}
