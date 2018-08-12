//
//  UIViewController+.swift
//  SiteDishBezorgApp
//
//  Created by Arjan van der Laan on 04-08-18.
//  Copyright © 2018 Arjan developing. All rights reserved.
//

import UIKit

extension UIViewController {
    static func getFromMain(withIdentifier identifier: String) -> UIViewController
    {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}

