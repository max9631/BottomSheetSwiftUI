//
//  BotomSheet.swift
//  MeteoritesSwiftUI
//
//  Created by Adam Salih on 28.04.2021.
//

import SwiftUI
import Combine

public struct BottomSheet<Anchor: BottomSheetAnchor, Master: View>: View {
    public var master: Master
    var sheet: Sheet
    
    @ObservedObject private var model: BottomSheetModel<Anchor>
    
    public init<Overlay: View>(anchor: Anchor.Type, master: Master, overlay: Overlay) {
        let model: BottomSheetModel<Anchor> = .init(overlay: overlay)
        self.model = model
        self.master = master
        self.sheet = Sheet(model: model.sheetModel)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                master
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    .environmentObject(model)
                sheet
                    .frame(width: geometry.size.width, alignment: .top)
                    .ignoresSafeArea(edges: .bottom)
                    .offset(y: model.offset)
                    .gesture(model.gesture)
                    .environmentObject(model)
            }
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(key: SheetSizePrefferenceKey.self, value: geometry.size)
                }
            )
            .onPreferenceChange(SheetSizePrefferenceKey.self) { self.model.size = $0 }
        }
    }
}
