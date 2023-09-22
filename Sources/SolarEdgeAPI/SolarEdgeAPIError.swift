//
//  SolarEdgeAPIError.swift
//  
//
//  Created by Andre Albach on 03.08.23.
//

import Foundation

/// A list of all the errors which can occour when using this API
public enum SolarEdgeAPIError: Error, CustomStringConvertible {
    case unmodified //304
    case badRequest //400
    case unauthorized //401
    case forbidden //402
    case notFound //404
    case conflict //409
    case unprocessableEntity //422
    case tooManyRequests //429
    case internalServerError //500
    
    case badURL
    
    case response
    case decoding(String)
    
    case describingError(String)
    
    /// The description of `self`
    public var description: String {
        switch self {
        case .unmodified:
            return "There is no new data. Content is unmodified."
        case .badRequest:
            return "Bad Request (400)"
        case .unauthorized:
            return "Unauthorized (401)"
        case .forbidden:
            return "Forbidden (403)"
        case .notFound:
            return "Not Found (404)"
        case .conflict:
            return "Conflict (409)"
        case .unprocessableEntity:
            return "Unprocessable Entity (422)"
        case .tooManyRequests:
            return "Too Many Requests (429)"
        case .internalServerError:
            return "Internal Server Error (500)"
            
        case .badURL:
            return "Bad URL"
            
        case .response:
            return "Unknown error with response"
        case .decoding(let error):
            return "Error while decoding. \(error)"
            
        case .describingError(let errorDescription):
            return errorDescription
        }
    }
    
    /// The localized discription of `self`
    public var localizedDescription: String { description }
}


extension SolarEdgeAPIError {
    
    /// A helper function for checking the status code
    /// - Parameter statusCode: The status code to check
    static func checkStatusCode(_ statusCode: Int) throws {
        switch statusCode {
        case 304: throw SolarEdgeAPIError.unmodified
        case 400: throw SolarEdgeAPIError.badRequest
        case 401: throw SolarEdgeAPIError.unauthorized
        case 403: throw SolarEdgeAPIError.forbidden
        case 404: throw SolarEdgeAPIError.notFound
        case 409: throw SolarEdgeAPIError.conflict
        case 422: throw SolarEdgeAPIError.unprocessableEntity
        case 429: throw SolarEdgeAPIError.tooManyRequests
        case 500: throw SolarEdgeAPIError.internalServerError
            
        case 200, 201, 204: return
            
        default: throw SolarEdgeAPIError.response
        }
    }
    
    /// A helper function to check the response and the data it comes with it
    /// - Parameters:
    ///   - data: The data which comes with the response
    ///   - response: The HTTP response object
    static func checkResponseWith(data: Data, response: HTTPURLResponse) throws {
        do {
            try checkStatusCode(response.statusCode)
        } catch {
            let _error = error as! SolarEdgeAPIError
            
            /// Try to read the exception message from the general error. Default with complete error description
            let json: [String: Any]?
            do {
                json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
            } catch {
                guard let dataString = String(data: data, encoding: .utf8) else { throw _error }
                throw SolarEdgeAPIError.describingError("\(_error.description)\n\n\(dataString)")
            }
            
            if let exceptionMessage = json?["ExceptionMessage"] as? String {
                throw SolarEdgeAPIError.describingError(exceptionMessage)
            } else if let message = json?["Message"] as? String {
                throw SolarEdgeAPIError.describingError(message)
            } else {
                guard let dataString = String(data: data, encoding: .utf8) else { throw _error }
                throw SolarEdgeAPIError.describingError("\(_error.description)\n\n\(dataString)")
            }
        }
    }
}
