//
//  Router.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import UIKit

final class MainRouter {
    private(set) var topViewController: UIViewController
    
    init(initialVC: UIViewController = ViewController()) {
        self.topViewController = UINavigationController(rootViewController: initialVC)
    }
}
