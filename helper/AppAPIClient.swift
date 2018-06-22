//
//  ApiConnector.swift
//  SiteDishBezorgApp
//
//  Created by Arjan van der Laan on 07-05-18.
//  Copyright © 2018 Arjan developing. All rights reserved.
//

import Foundation

enum ApiError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure
    var localizedDescription: String {
        switch self {
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        }
    }
}

struct ApiConnector {
    internal var urlSession: DHURLSession = URLSession.shared
    
    func getJsonForCodeable<D: Decodable>(decodeableType: D.Type, fromUrl dataUrl: URL, completion: @escaping (_ success: Bool, _ data: D?, _ error: ApiError?) -> Void) {
        //guard let dataUrl = URL(string: "https://sitedi.sh/order.php") else { return }
        urlSession.dataTask(with: dataUrl) { (data, response
            , error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, nil, .requestFailed)
                return
            }
            if httpResponse.statusCode == 200 {
                guard let data = data else { completion(/*succes:*/false, nil, .invalidData); return }
                do {
                    let decoder = JSONDecoder()
                    let urlData = try decoder.decode(decodeableType.self, from: data)
                    completion(/*success: */true, urlData, nil)
                } catch let err {
                    print("Err", err)
                    completion(false, nil, .jsonConversionFailure)
                }
            } else {
                completion(false, nil, .responseUnsuccessful)
            }
        }.resume()
    }
}
