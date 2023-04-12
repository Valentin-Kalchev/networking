//
//  URLEncodedBodyParameterEncoderTests.swift
//  
//
//  Created by Valentin Kalchev on 12/04/2023.
//

import XCTest
import Networking

final class URLEncodedBodyParameterEncoderTests: XCTestCase {

    func test_encode_invalidParameters_throwInvalidParametersTypeError() {
        
        let encoder = URLEncodedBodyParameterEncoder()

        var request = URLRequest(url: someURL)
        
        XCTAssertThrowsError(try encoder.encode(parameters: "invalid format", forRequest: &request)) { error in
            XCTAssertEqual(error as? ParameterEncodingError, ParameterEncodingError.invalidParametersType)
        }
    }
}

let someURL = URL(string: "https://someurl.com")!

