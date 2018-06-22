//
//  URL.swift
//  SiteDishBezorgApp
//
//  Created by Arjan van der Laan on 22-06-18.
//  Copyright © 2018 Arjan developing. All rights reserved.
//  originally from: github.com/ZamzamInc/ZamzamKit/blob/master/Sources/Extensions/URL.swift

import Foundation

public extension URL {
    
    /**
     Adds query string parameters to the URL
     
     - returns: a new URL with the mutated query string
     
     let url = URL(string: "https://google.com")!
     let param = ["q": "Swifter Swift"]
     url.appendingQueryParameters(params) -> "https://google.com?q=Swifter%20Swift"
     */
    public func appendingQueryItems(_ parameters: [String: String]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        var items = urlComponents.queryItems ?? []
        items += parameters.map({ URLQueryItem(name: $0, value: $1) })
        urlComponents.queryItems = items
        return urlComponents.url!
    }
    
}
