//
//  ButtonMusicView.swift
//  Player
//
//  Created by Муртазали Магомедов on 09.10.2024.
//

import SwiftUI

struct ButtonMusicView: View {
    let buttonName: String
    let size: CGFloat
    let color: Color
    let action: () -> ()
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: buttonName)
                .resizable()
                .frame(width: size, height: size, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .foregroundColor(color)
        }
    }
}

#Preview {
    MainView()
}
