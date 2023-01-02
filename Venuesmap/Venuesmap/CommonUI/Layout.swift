//
//  Layout.swift
//  Venuesmap
//
//  Created by oroom on 2023-01-01.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    static func add(subview: UIView, to superview: UIView) {
        superview.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: superview.topAnchor),
            subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
}

extension CGFloat {
    static let margin = 4.0
    static let margin2 = margin*2
    static let margin4 = margin*4
}
