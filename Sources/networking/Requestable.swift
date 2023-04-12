//
//  Requestable.swift
//  Networking
//
//  Created by Valentin Kalchev on 12/01/2022.
//

import Foundation

/**
 HTTP method definitions.
 */

public enum HTTPMethod: String {
    
    case connect = "CONNECT"
    case delete = "DELETE"
    case get = "GET"
    case head = "HEAD"
    case options = "OPTIONS"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case trace = "TRACE"
}

/**
 The media type (MIME type) sent as part of the request.
 */

public enum RequestContentType: String {
    
    case json = "application/json"
    case urlEncoded = "application/x-www-form-urlencoded"
}

/**
 The media type (MIME type) of the response accepted by the client.
 */

public enum RequestAcceptType: String {
    
    case json = "application/json"
    case urlEncoded = "application/x-www-form-urlencoded"
}

public enum AuthorizationType {
    
    case none
    case bearer
}

public enum ParameterEncoding {
    
    case urlEncodedBody
    case queryString
    case json
    case rawData
}

public protocol Requestable {
    
    // MARK: - Methods.
    
    func performRequest<T>(to url: String,
                           httpMethod: HTTPMethod,
                           headers: [String : String]?,
                           authorizationType: AuthorizationType,
                           contentType: RequestContentType,
                           parameters: Any?,
                           encoding: ParameterEncoding?) async throws -> T where T: Decodable
}

extension Requestable {
    
     public func performRequest<T>(to url: String,
                           httpMethod: HTTPMethod,
                           headers: [String : String]? = nil,
                           authorizationType: AuthorizationType = .bearer,
                           contentType: RequestContentType = .json,
                           parameters: Any? = nil,
                           encoding: ParameterEncoding? = .json) async throws -> T where T: Decodable {
         
        return try await performRequest(to: url, httpMethod: httpMethod, headers: headers, authorizationType: authorizationType, contentType: contentType, parameters: parameters, encoding: encoding)
    }
}
