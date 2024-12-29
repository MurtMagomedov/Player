//
//  Extension+ext.swift
//  Player
//
//  Created by Муртазали Магомедов on 18.09.2024.
//

import Foundation
import SwiftUI

extension Text {
    func textFont() -> some View{
        self
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .light, design: .rounded))
    }
}
