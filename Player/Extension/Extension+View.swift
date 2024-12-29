//
//  Extension+View.swift
//  Player
//
//  Created by Муртазали Магомедов on 09.10.2024.
//

import Foundation
import SwiftUI

struct TextFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .light, design: .rounded))
    }
}

extension View {
    func durationFont() -> some View {
        self.modifier(TextFontModifier())
    }
}
