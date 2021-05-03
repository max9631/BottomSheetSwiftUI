//
//  Sheet.swift
//  MeteoritesSwiftUI
//
//  Created by Adam Salih on 28.04.2021.
//

import SwiftUI

class SheetModel: ObservableObject {
    @Published var contentSize: CGSize = .zero
    @Published var stack: [AnyView]
    var offsets: [CGFloat?] = []
    
    init<ViewType: View>(initialOverlay: ViewType) {
        stack = [AnyView(initialOverlay)]
    }
    
    
    func push<ViewType: View, Anchor: BottomSheetAnchor>(lastViewOffset: CGFloat, view: ViewType, initialAnchor: Anchor) {
        stack.append(AnyView(view))
        offsets.append(lastViewOffset)
    }
    
    func pop() -> CGFloat? {
        _ = stack.popLast()
        return offsets.popLast() as? CGFloat
    }
}

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
