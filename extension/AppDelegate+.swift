//
//  AppDelegate.swift
//  SiteDishBezorgApp
//
//  Created by Arjan van der Laan on 25-06-18.
//  Copyright © 2018 Arjan developing. All rights reserved.
//

import UIKit

extension AppDelegate {
    
    /// Necessary to register what you set as default value for
    /// a Settings.bundle setting, as the actual value. Without
    /// doing this, the value is nil.
    /// - Requires: - the settings bundle's name to be
    /// `Settings.bundle` having a file `Root.plist`.
    func registerDefaultsFromSettingsBundle()
    {
        let settingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
        let settingsPlist = NSDictionary(contentsOf:settingsUrl)!
        let preferences = settingsPlist["PreferenceSpecifiers"] as! [NSDictionary]
        
        var defaultsToRegister = Dictionary<String, Any>()
        
        for preference in preferences {
            guard let key = preference["Key"] as? String else {
                print("Settings key not found")
                continue
            }
            defaultsToRegister[key] = preference["DefaultValue"]
        }
        UserDefaults.standard.register(defaults: defaultsToRegister)
    }
}
