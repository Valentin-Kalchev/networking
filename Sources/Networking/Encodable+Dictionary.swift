//
//  Encodable+Dictionary.swift
//  Networking
//
//  Created by Valentin Kalchev on 20/01/2022.
//

import Foundation
 
extension Encodable {
    
    public var dictionaryRepresentation: [String: Any]? {
        
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
