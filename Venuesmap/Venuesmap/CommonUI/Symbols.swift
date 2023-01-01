//
//  Symbols.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import UIKit

extension UIImage {
    static var sfLocation: UIImage {
        let config = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let image = UIImage(systemName: "location", withConfiguration: config)!
        return image
    }
    
    static var sfLocationSlach: UIImage {
        let config = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let image = UIImage(systemName: "location.slash", withConfiguration: config)!
        return image
    }
    
    static var sfLocationGrant: UIImage {
        let config = UIImage.SymbolConfiguration(textStyle: .caption1)
        let image = UIImage(systemName: "lock.open", withConfiguration: config)!
        return image
    }
}
