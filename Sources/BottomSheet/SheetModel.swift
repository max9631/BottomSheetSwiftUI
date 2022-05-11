//
//  File.swift
//  
//
//  Created by Adam Salih on 09.05.2022.
//

import SwiftUI

class SheetModel: ObservableObject {
    @Published var contentSize: CGSize = .zero
    @Published var stack: [AnyView]
    private var pastOffsets: [CGFloat?] = []

    init<ViewType: View>(initialOverlay: ViewType) {
        stack = [AnyView(initialOverlay)]
    }


    func push<ViewType: View, Anchor: BottomSheetAnchor>(lastViewOffset: CGFloat, view: ViewType, initialAnchor: Anchor) {
        stack.append(AnyView(view))
        pastOffsets.append(lastViewOffset)
    }

    func pop() -> CGFloat? {
        _ = stack.popLast()
        return pastOffsets.popLast() as? CGFloat
    }
}
