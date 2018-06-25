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
     Add, update, or remove a query string parameter from the URL
     
     - parameter url:   the URL
     - parameter key:   the key of the query string parameter
     - parameter value: the value to replace the query string parameter, nil will remove item
     
     - returns: the URL with the mutated query string
     */
    func appendingQueryItem(_ name: String, value: Any?) -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            print("could not retrieve URLComponents")
            return self
        }
        
        urlComponents.queryItems = urlComponents.queryItems?
            .filter { $0.name.lowercased() != name.lowercased() } ?? []
        
        // Skip if nil value
        if let value = value {
            urlComponents.queryItems?.append(URLQueryItem(name: name, value: "\(value)"))
        }
        
        return urlComponents.url ?? self
    }
    
}
