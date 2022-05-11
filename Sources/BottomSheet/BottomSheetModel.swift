//
//  File.swift
//  
//
//  Created by Adam Salih on 09.05.2022.
//

import SwiftUI
import Combine

public class BottomSheetModel<Anchor: BottomSheetAnchor>: ObservableObject {
    @Published public var scrollViewAxis: Axis.Set = []
    @Published public var shouldScroll: Bool = true
    @Published var offset: CGFloat = .zero
    var size: CGSize = .zero

    var sheetModel: SheetModel

    private var startOffset: CGFloat? = nil
    private var scrollDirectionUp: Bool? = nil
    private var cancellables: Set<AnyCancellable> = Set()
    private let animationDuration: Double = 0.4

    init<ViewType: View>(overlay: ViewType) {
        sheetModel = .init(initialOverlay: overlay)
        $shouldScroll
            .receive(on: DispatchQueue.main)
            .map { scroll -> Axis.Set in scroll ? [.vertical] : [] }
            .sink { [weak self] axis in self?.scrollViewAxis = axis}
            .store(in: &cancellables)
        $offset
            .receive(on: DispatchQueue.main)
            .map { offset in offset <= 0 }
            .sink { [weak self] scroll in self?.shouldScroll = scroll  }
            .store(in: &cancellables)
    }

    var gesture: some Gesture {
        DragGesture()
            .onChanged(slide(gesture:))
            .onEnded(endSlide(gesture:))
    }

    public func slide(to anchor: Anchor) {
        self.setOffset(offset: anchor.offset)
    }

    public func push<ViewType: View>(view: ViewType, initialAnchor: Anchor) {
        let offset = offset
        let animationDuration = animationDuration
        setOffset(offset: .specific(offset: 0), animation: .easeOut(duration: animationDuration))
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            self?.sheetModel.push(lastViewOffset: offset, view: view, initialAnchor: initialAnchor)
            self?.setOffset(offset: .specific(offset: 0), animation: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.setOffset(offset: initialAnchor.offset, animation: .easeIn(duration: animationDuration))
            }
        }
    }

    public func pop() {
        guard !sheetModel.stack.isEmpty else {
            return
        }
        let animationDuration = animationDuration
        setOffset(offset: .specific(offset: 0), animation: .easeOut(duration: animationDuration))
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            let offset = self?.sheetModel.pop()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                if let offset = offset{
                    self?.setOffset(constant: offset, animation: .easeIn(duration: animationDuration))
                } else {
                    self?.setOffset(offset: .relative(percentage: 1), animation: .easeIn(duration: animationDuration))
                }
            }
        }
    }

    private func slide(gesture: DragGesture.Value) {
        guard let offset = startOffset else {
            self.startOffset = self.offset
            return
        }
        scrollDirectionUp = offset + gesture.translation.height < self.offset
        self.offset = offset + gesture.translation.height
    }

    private func endSlide(gesture: DragGesture.Value) {
        let projection = (startOffset ?? .zero) + gesture.predictedEndTranslation.height
        setOffset(offset: nearestOffset(for: projection))
        startOffset = nil
    }

    private func constant(for offset: BottomSheetOffset) -> CGFloat {
        let bottomOffset: CGFloat = {
            let constant: CGFloat = {
                switch offset {
                case let .specific(offset):
                    return offset
                case let .relative(percentage, offsettedBy):
                    let height = sheetModel.contentSize.height
                    return (height * percentage.clamp(from: 0, to: 1)) + offsettedBy
                }
            }()
            if constant > sheetModel.contentSize.height {
                return sheetModel.contentSize.height
            }
            return constant
        }()
        if bottomOffset <= 0 {
            return size.height - bottomOffset
        }
        return sheetModel.contentSize.height - bottomOffset
    }

    private func nearestOffset(for projection: CGFloat) -> BottomSheetOffset {
        let offsets = Array(Anchor.allCases)
        let nearestIndex = offsets
            .map(\.offset)
            .map(constant(for:))
            .enumerated()
            .map { index, offset in (index, abs(offset - projection)) }
            .min { $0.1 < $1.1 }?.0
        return nearestIndex != nil ? offsets[nearestIndex!].offset : .specific(offset: .zero)
    }

    func setOffset(offset: BottomSheetOffset, animation: Animation? = .interactiveSpring()) {
        setOffset(constant: constant(for: offset), animation: animation)
    }

    func setOffset(constant: CGFloat, animation: Animation? = .interactiveSpring()) {
        let closure = {
            self.offset = constant
        }
        if let animation = animation {
            withAnimation(animation, closure)
        } else {
            closure()
        }
    }
}

