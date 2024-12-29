//
//  CellSongView.swift
//  Player
//
//  Created by Муртазали Магомедов on 18.09.2024.
//

import SwiftUI

struct CellSongView: View {
    
    let song: SongModel
    
    let durationFormater: (TimeInterval) -> String
    var body: some View {
        HStack {
            
            if let data = song.coverImage, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                Image(systemName: "music.note")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .foregroundColor(.white)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            VStack(alignment: .leading) {
                Text(song.name)
                Text(song.artist ?? "Unowned Artist")
            }
            
            Spacer()
            if let duration = song.duration {
                Text(durationFormater(duration))
            }
        }
    }
}

#Preview {
    MainView()
}
