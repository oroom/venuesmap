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
