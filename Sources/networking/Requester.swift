//
//  Requester.swift
//  Networking
//
//  Created by Valentin Kalchev on 13/01/2022.
//

import Foundation

public protocol RequesterDelegate: AnyObject {
    
    func headersDictionary(forContentType contentType: RequestContentType,
                           acceptType: RequestAcceptType,
                           authorizationType: AuthorizationType,
                           url: String,
                           httpMethod: HTTPMethod) -> [String: String]
}

public final class Requester {
    
    // MARK: - Properties.
    
    public weak var delegate: RequesterDelegate?
    
    private let jsonDecoder: JSONDecoder
    private let session: URLSession
    
    private lazy var encodersDictionary: [ParameterEncoding: ParameterEncoder] = [.urlEncodedBody: URLEncodedBodyParameterEncoder(),
                                                                                  .json: JSONParameterEncoder(),
                                                                                  .queryString: URLParameterEncoder(),
                                                                                  .rawData: DataParameterEncoder()]
    // MARK: - Life Cycle.
    
    public init(jsonDecoder: JSONDecoder, session: URLSession = .shared, delegate: RequesterDelegate?) {
        
        self.jsonDecoder = jsonDecoder
        self.session = session
        self.delegate = delegate
    }
}

// MARK: - Public Methods.

extension Requester {
    
    public func performRequest<T>(to url: String,
                                  httpMethod: HTTPMethod,
                                  headers: [String : String]? = nil,
                                  authorizationType: AuthorizationType = .bearer,
                                  contentType: RequestContentType = .json,
                                  parameters: Any? = nil,
                                  encoding: ParameterEncoding? = .json,
                                  cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                  timeoutInterval: TimeInterval = 60) async throws -> T where T: Decodable {
        
        var headerDictionary = delegate?.headersDictionary(forContentType: contentType,
                                                           acceptType: .json,
                                                           authorizationType: authorizationType,
                                                           url: url,
                                                           httpMethod: httpMethod)
        
        if let headers = headers {
            headerDictionary?.merge(headers) { (_, new) -> String in new }
        }
        
        let encoder = (encoding != nil) ? encodersDictionary[encoding!] : nil
        
        let request = try URLRequest.build(url: url,
                                           parameters: parameters,
                                           encoder: encoder,
                                           headers: headerDictionary,
                                           httpMethod: httpMethod.rawValue,
                                           cachePolicy: cachePolicy,
                                           timeoutInterval: timeoutInterval)
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw RequesterError.incorrectResponseType
        }
        
        return try handleResponse(response, withData: data)
    }
}

// MARK: - Private Methods.

extension Requester {
    
    private func handleResponse<T: Decodable>(_ response: HTTPURLResponse, withData data: Data?) throws -> T {
        
        let statusCode = response.statusCode
        
        switch statusCode {
        case 200..<300:
            
            guard let data = data else {
                throw DataResponseError(message: "Missing data")
            }
            
            return try jsonDecoder.decode(T.self, from: data.isEmpty ? Data("{}".utf8) : data)
            
        case 404:
            throw HTTPResponseError(statusCode: statusCode, message: "Route or resource not found")
            
        case 400, 402, 403, 405...499:
            throw HTTPResponseError(statusCode: statusCode)
            
        default:
            throw HTTPResponseError(statusCode: statusCode, message: "Server not responding")
        }
    }
}

// MARK: - Definitions.

extension Requester {
    
    public enum RequesterError: Swift.Error {
        
        case incorrectResponseType
        case invalidURL
    }
    
    public struct DataResponseError: LocalizedError {
        
        // MARK: - Properties.
        
        /**
         The error's message.
         */
        
        public let message: String?
        
        public var errorDescription: String? {
            return message
        }
        
        //MARK: - Life Cycle.
        
        public init(message: String? = nil) {
            self.message = message
        }
    }
    
    public struct HTTPResponseError: LocalizedError {
        
        // MARK: - Properties.
        
        /**
         HTTP status code
         */
        public let statusCode: Int
        
        /**
         The error's message.
         */
        public let message: String?
        
        public var errorDescription: String? {
            return message
        }
        
        // MARK: - Life Cycle.
        
        public init(statusCode: Int, message: String? = nil) {
            
            self.statusCode = statusCode
            self.message = message
        }
    }
}

extension URLRequest {
    
    public enum URLRequestError: Swift.Error {
        case invalidURL
    }
    
    fileprivate static func build(url: String,
                                  parameters: Any? = nil,
                                  encoder: ParameterEncoder? = nil,
                                  headers: [String: String]? = nil,
                                  httpMethod: String,
                                  cachePolicy: CachePolicy,
                                  timeoutInterval: TimeInterval) throws -> URLRequest {
        
        guard let url = URL(string: url) else {
            throw(URLRequestError.invalidURL)
        }
        
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        
        if let parameters = parameters, let encoder = encoder {
            try encoder.encode(parameters: parameters, forRequest: &request)
        }
        
        headers?.forEach({ (header, value) in
            request.addValue(value, forHTTPHeaderField: header)
        })
        
        request.httpMethod = httpMethod
        
        return request
    }
}
