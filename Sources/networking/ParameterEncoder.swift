//
//  ParameterEncoder.swift
//  Networking
//
//  Created by Valentin Kalchev on 13/01/2022.
//

import Foundation

/**
 An `enum` representing all the possible errors when using a `ParameterEncoder`.
 */

public enum ParameterEncodingError: Error {
    
    /**
     JSON serialization failed to convert the parameters to a JSON object.
     */
    
    case jsonSerializationFailure
    
    /**
     The given request to encode is not valid.
     */
    
    case invalidRequest
    
    /**
     The result query string with the given parameters is not valid.
     */
    
    case invalidQueryString
    
    /**
     The provided parameters are not of the expected `Type` for the used
     `ParameterEncoder`.
     */
    
    case invalidParametersType
}

/**
 This protocol is a generic request encoder interface used to encode the given parameters into a request
 */

public protocol ParameterEncoder {
    
    /**
     Encode the given parameters into the given request
     
     - parameter parameters: a dictionary of parameters to encode and add to the request
     - parameter request: the request to add the encoded parameter to
     */
    
    func encode(parameters: Any, forRequest request: inout URLRequest) throws
}

/**
 Encodes the given parameters into a JSON object and add it to the request body.
 */

public struct JSONParameterEncoder: ParameterEncoder {
    
    public init() {}
    
    public func encode(parameters: Any, forRequest request: inout URLRequest) throws {
        
        var body: Data!
        
        do {
            try body = JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            
        } catch {
            throw(ParameterEncodingError.jsonSerializationFailure)
        }
        
#if DEBUG
        print(String(data: body, encoding: .utf8)!)
#endif
        request.httpBody = body
    }
}

/**
 Encodes the given parameters into a URL query string and add it to the request body.
 */

public struct URLEncodedBodyParameterEncoder: ParameterEncoder {
    
    public init() {}
    
    public func encode(parameters: Any, forRequest request: inout URLRequest) throws {
        
        guard let parametersDictionary = parameters as? [String: Any] else {
            throw(ParameterEncodingError.invalidParametersType)
        }
        
        guard let url = request.url, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw(ParameterEncodingError.invalidRequest)
        }
        
        urlComponents.queryItems = parametersDictionary.rfc3986Encoded().compactMap { parameter, value in
            return URLQueryItem(name: parameter, value: value)
        }
        
        guard let body = urlComponents.query?.data(using: .utf8) else {
            throw(ParameterEncodingError.invalidRequest)
        }
        
#if DEBUG
        print(String(data: body, encoding: .utf8)!)
#endif
        request.httpBody = body
    }
}

/**
 Encodes the given parameters into the request URL.
 */

public struct URLParameterEncoder: ParameterEncoder {
    
    public init() {}
    
    public func encode(parameters: Any, forRequest request: inout URLRequest) throws {
        
        guard let parametersDictionary = parameters as? [String: Any] else {
            throw(ParameterEncodingError.invalidParametersType)
        }
        
        guard let url = request.url, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw(ParameterEncodingError.invalidRequest)
        }
        
        urlComponents.queryItems = parametersDictionary.map { URLQueryItem(name: $0, value: "\($1)") }
        
        guard let query = urlComponents.query, query.count > 0 else {
            throw(ParameterEncodingError.invalidQueryString)
        }
        
        request.url = urlComponents.url
    }
}

/**
 Add the provided `Data` parameter to the URL request's `httpBody`. No actual encoding is needed.
 */

public struct DataParameterEncoder: ParameterEncoder {
    
    public init() {}
    
    public func encode(parameters: Any, forRequest request: inout URLRequest) throws {
        
        guard let parametersData = parameters as? Data else {
            throw(ParameterEncodingError.invalidParametersType)
        }
        
        request.httpBody = parametersData
    }
}


fileprivate extension Dictionary where Key == String, Value == Any {
    
    /**
     Convert a [String: Any] dictionary to a [String: String] percent escaped values allowing RFC3986 characters
     */
    
    func rfc3986Encoded() -> [String: String] {
        
        var rfcMap = [String: String]()
        
        self.forEach { (key, value) in
            
            if let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved) {
                rfcMap[key] = escapedValue
            }
        }
        
        return rfcMap
    }
}

fileprivate extension CharacterSet {
    
    /**
     RFC3986 Unreserved CharacterSet extension
     */
    static let rfc3986Unreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
}

