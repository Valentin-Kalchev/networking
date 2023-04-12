//
//  RequestableSample.swift
//  Networking
//
//  Created by Valentin Kalchev on 12/01/2022.
//

import Foundation

/*
 Use delegation to get dynamic data such as access token.
 */
protocol RequestableSampleDelegate: AnyObject {
    
    func requestableSampleDidRequestAccessToken(_ requestManager: RequestableSample) -> String
    func requestableSampleDidRequestUserAgent(_ requestManager: RequestableSample) -> String
}

/*
 USE ONLY AS A REFERENCE
 */
final class RequestableSample {
    
    // MARK: - Constants.
    
    private let requester: Requester
    private weak var delegate: RequestableSampleDelegate?
    
    // MARK: - Life Cycle.
    
    init(delegate: RequestableSampleDelegate) {
        
        self.delegate = delegate
        
        /*
         Decoder can be injected as part of the initializer
         */
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        self.requester = Requester(jsonDecoder: jsonDecoder, delegate: nil)
        
        defer {
            self.requester.delegate = self
        }
    }
}

// MARK: - Requestable.

extension RequestableSample: Requestable {
    
    public func performRequest<T>(to url: String,
                                  httpMethod: Networking.HTTPMethod,
                                  headers: [String : String]?,
                                  authorizationType: Networking.AuthorizationType,
                                  contentType: Networking.RequestContentType,
                                  parameters: Any?,
                                  encoding: Networking.ParameterEncoding?) async throws -> T where T : Decodable {
        
        return try await requester.performRequest(to: url, httpMethod: httpMethod, authorizationType: authorizationType, contentType: contentType, parameters: parameters, encoding: encoding)
    }
}

// MARK: - RequesterDelegate.

extension RequestableSample: RequesterDelegate {
    
    func headersDictionary(forContentType contentType: RequestContentType,
                                  acceptType: RequestAcceptType,
                                  authorizationType: AuthorizationType,
                                  url: String,
                                  httpMethod: HTTPMethod) -> [String : String] {
        
        /*
         Provide default headers for every request. You can omit the header(s) by providing an override when calling `perfromRequest(..., headers: ...)`
         */
        
        var headers = [String: String]()
        
        headers["Content-Type"] = contentType.rawValue
        headers["Accept"] = acceptType.rawValue
        
        if let userAgent = delegate?.requestableSampleDidRequestUserAgent(self) {
            headers["User-Agent"] = userAgent
        }
        
        if case .bearer = authorizationType, let accessToken = delegate?.requestableSampleDidRequestAccessToken(self) {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return headers
    }
}
