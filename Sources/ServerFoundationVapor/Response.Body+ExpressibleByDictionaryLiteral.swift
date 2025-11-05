//
//  Response.Body:ExpressibleByDictionaryLiteral.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 12/09/2024.
//

import Foundation
import Vapor

extension Response.Body: @retroactive ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        let dictionary = Dictionary(uniqueKeysWithValues: elements)
        let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        self = .init(data: jsonData)
    }
}
