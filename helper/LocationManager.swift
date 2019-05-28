//
//  LocationManager.swift
//  SiteDishBezorgApp
//
//  Created by Arjan van der Laan on 09-03-19.
//  Copyright © 2019 Arjan van der Laan. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationAuthorizationStatus {
    static func converted(from status: CLAuthorizationStatus) -> LocationAuthorizationStatus {
        switch status {
        case .authorizedWhenInUse: return .authorizedWhenInUse
        case .authorizedAlways: return .authorizedAlways
        case .restricted: return .restricted
        case .denied : return .denied
        default: return .notDetermined
        }
    }
    
    case notDetermined
    case authorizedWhenInUse
    case authorizedAlways
    case restricted
    case denied
}

/**
 - note: default = `hundredMeters`
 */
enum LocationAccuracy {
    case bestForNavigation
    case nearestTenMeters
    case hundredMeters // default
    
    func converted() -> CLLocationAccuracy {
        switch self {
        case .bestForNavigation:
            return kCLLocationAccuracyBestForNavigation
        case .nearestTenMeters:
            return kCLLocationAccuracyNearestTenMeters
        default:
            return kCLLocationAccuracyHundredMeters
        }
    }
    
//    public let kCLLocationAccuracyBestForNavigation: CLLocationAccuracy
//    public let kCLLocationAccuracyBest: CLLocationAccuracy
//    public let kCLLocationAccuracyNearestTenMeters: CLLocationAccuracy
//    public let kCLLocationAccuracyHundredMeters: CLLocationAccuracy
//    public let kCLLocationAccuracyKilometer: CLLocationAccuracy
//    public let kCLLocationAccuracyThreeKilometers: CLLocationAccuracy
}

struct LocationCoordinate {
    var latitude: Double
    var longitude: Double
    var timestamp: Date
};

protocol LocationManagerDelegate {
    func locationManager(_ manager: LocationManager, didChangeAuthorization status: LocationAuthorizationStatus);
    func locationManager(_ manager: LocationManager, didUpdateLocations locations: [LocationCoordinate])
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    var delegate: LocationManagerDelegate?
    var currentLocation : LocationCoordinate? = nil
    
    var allowsBackgroundLocationUpdates = false { didSet { locationManager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates } }
    var pausesLocationUpdatesAutomatically = true { didSet { locationManager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically } }
    
    private override init() { super.init(); locationManager.delegate = self }
    
    var currentAuthorizationStatus: LocationAuthorizationStatus {
        return LocationAuthorizationStatus.converted(from: CLLocationManager.authorizationStatus())
    }

    private let locationManager = CLLocationManager()
    
//    func startUpdating(with desiredAccuracy: LocationAccuracy) {
//        locationManager.desiredAccuracy = desiredAccuracy.converted()
//        locationManager.startUpdatingLocation()
//    }
    
    /**
     - returns: whether or not location services could be requested
     */
    func requestWhenInUseLocationServices() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return true
        }
        
        return false
    }
    
    /**
     - returns: whether or not location services could be requested
     */
    func requestAlwaysLocationServices() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            return true
        }
        
        return false
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.locationManager(self, didChangeAuthorization: LocationAuthorizationStatus.converted(from: status))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let last = locations.last {
            currentLocation = LocationCoordinate(latitude: last.coordinate.latitude, longitude: last.coordinate.longitude, timestamp: last.timestamp)
            delegate?.locationManager(self, didUpdateLocations: locations.map() { LocationCoordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude, timestamp: $0.timestamp) })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func requestLocation() { locationManager.requestLocation() }
}

