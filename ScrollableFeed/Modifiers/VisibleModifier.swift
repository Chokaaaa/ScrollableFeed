//
//  VisibleModifier.swift
//  ScrollableFeed
//
//  Created by Nursultan Yelemessov on 27/02/2025.
//

import Foundation
import SwiftUI

struct VisibleModifier: ViewModifier {
    let onChange: (Bool) -> Void
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { proxy in
                Color.clear
                    .preference(key: VisibilityPreferenceKey.self, value: UIScreen.main.bounds.intersects(proxy.frame(in: .global)))
            })
            .onPreferenceChange(VisibilityPreferenceKey.self, perform: onChange)
    }
}

struct VisibilityPreferenceKey: PreferenceKey {
    typealias Value = Bool
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

extension View {
    func onVisibilityChange(_ action: @escaping (Bool) -> Void) -> some View {
        self.modifier(VisibleModifier(onChange: action))
    }
}
