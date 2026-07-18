//
//  Locale.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2024.
//

import Foundation
import Vapor

extension Vapor.Request {
    public var locale: Locale { .init(request: self) }
}

extension Foundation.Locale {
    public init(
        request: Vapor.Request
    ) {
        if let acceptLanguage = request.headers.first(name: HTTPHeaders.Name.acceptLanguage) {
            let languages = acceptLanguage.split(separator: ",").map { substring in
                let components = substring.split(separator: ";")
                return String(components.first!)
            }

            if let primaryLanguage = languages.first {
                self.init(identifier: primaryLanguage)
                return
            }
        }
        // Fallback to a default locale if no valid language is found
        self.init(identifier: "en_US")
    }
}
