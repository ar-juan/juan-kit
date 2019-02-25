# juan-kit
Useful Swift extensions and classes

1. Extensions

1.1 URL
1.1.1 
- Appending a query item
- Appending multiple query items

1.2 AppDelegate
- registerDefaultsFromSettingsBundle

2. Helpers

2.1 Networking
2.1.1 App API client
- Specific network error enum
- Get JSON immediately using `Codable`  entities from an URL
2.1.2 DH URL session mock
- Fake NSURLSession for testing purposes

2.2 Geocoding
2.1.1 App geocoder
- Geocode an address string to a MKPlacemark with(out) caching
- Calculate the distance between MKPlacemarks

2.3 Video
2.3.1 AV code reader
- Reads QR codes (also able to set up for bar codes)

2.4 Logging
2.4.1 LogMe
- Removes clutter from NSLog
- Adds file and line number
- Adds logging levels (Debug, Info, Warn, Error)

3. Classes
3.1 UIView
3.1.1 ReusableXibView
- Loads a view from a equally named XIB
