//
//  Comparable+Extensions.swift
//  MeteoritesSwiftUI
//
//  Created by Adam Salih on 27.04.2021.
//

import Foundation

extension Comparable {
    func clamp(from: Self, to: Self) -> Self {
        switch self {
        case let x where x < from:
            return from
        case let x where x > to:
            return to
        default:
            return self
        }
    }
}
