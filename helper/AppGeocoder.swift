//
//  AppGeocoder.swift
//  SiteDishBezorgApp
//
//  Created by Arjan van der Laan on 10-05-18.
//  Copyright © 2018 Arjan developing. All rights reserved.
//

import Foundation
import MapKit

struct AppGeocoder {
    /// Cache the results in UserDefaults?
    var cacheResults = false
    
    /// Creates MKPlacemark for a `from` and a `to` location and caches the result in `UserDefaults`
    /// - Parameter to: Een string met adres, bijv. "Straatweg 1, 1234AB, Rotterdam"
    /// - Parameter from: idem
    /// - Parameter completion: wat te doen zodra compleet
    func geocode(to: String?, from: String?, completion: @escaping (_ to: MKPlacemark?, _ from: MKPlacemark?) -> Void) {
        if
            cacheResults,
            let fromString = from,
            let fromPropertyList = UserDefaults.standard.object(forKey: fromString) as? Data,
            let fromPlacemark = NSKeyedUnarchiver.unarchiveObject(with: fromPropertyList) as? MKPlacemark,
            let toString = to,
            let toPropertyList = UserDefaults.standard.object(forKey: toString) as? Data,
            let toPlacemark = NSKeyedUnarchiver.unarchiveObject(with: toPropertyList) as? MKPlacemark
        {
            completion(toPlacemark, fromPlacemark)
        } else {
            let glc = CLGeocoder()
            let region: CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 52.256680, longitude: 5.373074), radius: 180000, identifier: "Nederland")
            if let toString = to {
                glc.geocodeAddressString(toString, in: region, completionHandler: { (placeMarks: [CLPlacemark]?, error: Error?) in
                    guard let toLocation = placeMarks?.first else { return }
                    let toPlacemark = MKPlacemark(placemark: toLocation)
                    
                    let encodedToPlacemark = NSKeyedArchiver.archivedData(withRootObject: toPlacemark)
                    
                    if self.cacheResults { UserDefaults.standard.set(encodedToPlacemark, forKey: toString) }
                    
                    if let fromString = from {
                        glc.geocodeAddressString(fromString, in: region, completionHandler: { (placeMarks: [CLPlacemark]?, error: Error?) in
                            guard let fromLocation = placeMarks?.first else { return }
                            let fromPlacemark = MKPlacemark(placemark: fromLocation)
                            
                            let encodedFromPlacemark = NSKeyedArchiver.archivedData(withRootObject: fromPlacemark)
                            if self.cacheResults { UserDefaults.standard.set(encodedFromPlacemark, forKey: fromString) }
                            
                            completion(toPlacemark, fromPlacemark)
                        })
                        
                    } else {
                        // just the .to
                        completion(toPlacemark,nil)
                    }
                }) // ** geocodeAddressString
            } // ** if let
        } // ** else
    }
    
    func distance(to: MKPlacemark?, from: MKPlacemark?, completion: @escaping (_ distanceString: String) -> Void) {
        guard let fromPlacemark = from, let toPlacemark = to else { print("cannot calculate distance"); return }
        
        let request: MKDirectionsRequest = MKDirectionsRequest()
        request.destination = MKMapItem(placemark: toPlacemark)
        request.source = MKMapItem(placemark: fromPlacemark)
        
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: { (response: MKDirectionsResponse?, error: Error?) in
            if let routeResponse = response, let distance = routeResponse.routes.first?.distance {
                    let mkDistanceFormatter = MKDistanceFormatter()
                    mkDistanceFormatter.locale = Locale(identifier: "nl-NL")
                    mkDistanceFormatter.unitStyle = .abbreviated
                    let distanceString = mkDistanceFormatter.string(fromDistance: distance)
                    completion(distanceString)
            } else {
                print(error?.localizedDescription ?? "unknown error @ directions request")
            }
        })
    }
}
