//
//  Sheet.swift
//  MeteoritesSwiftUI
//
//  Created by Adam Salih on 28.04.2021.
//

import SwiftUI

struct Sheet: View {
    @ObservedObject var model: SheetModel
    
    init(model: SheetModel) {
        self.model = model
    }
    
    var body: some View {
        if let first = model.stack.last {
            first
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: SheetSizePrefferenceKey.self, value: geometry.size)
                    }
                )
                .onPreferenceChange(SheetSizePrefferenceKey.self) { self.model.contentSize = $0 }
        } else {
            Rectangle()
        }
    }
}

struct SheetSizePrefferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value _: inout CGSize, nextValue: () -> CGSize) {
        _ = nextValue()
    }
}
