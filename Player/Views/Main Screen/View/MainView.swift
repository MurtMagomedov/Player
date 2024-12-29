import SwiftUI
import RealmSwift

struct MainView: View {
    @ObservedResults(SongModel.self) var songs
    @StateObject var vm = ViewModel()
    @State private var showFiles = false
    @State private var showDetails = false
    @State private var isDraging = false
    @Namespace private var playAnimation
    
    var imageSize: CGFloat {
        showDetails ? 350 : 50
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack {
                    // List of Songs
                    List {
                        ForEach(songs) { song in
                            CellSongView(song: song, durationFormater: vm.durationFormater)
                                .onTapGesture {
                                    vm.playAudio(song: song)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: $songs.remove)
                    }
                    .listStyle(.plain)
                    
                    // Player
                    if vm.currentSong != nil {
                        Player()
                            .frame(height: showDetails ? UIScreen.main.bounds.height + 250 : 70)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    showDetails.toggle()
                                }
                            }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ButtonMusicView(buttonName: "plus", size: 25, color: .blue) {
                        showFiles.toggle()
                    }
                }
            }
            .sheet(isPresented: $showFiles) {
                ImportFileManager()
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    vm.updateProgress()
                }
            }
        }
    }
    
    @ViewBuilder
    private func Player() -> some View {
        VStack {
            HStack {
                if let data = vm.currentSong?.coverImage, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageSize, height: imageSize)
                        .cornerRadius(15)
                } else {
                    Image(systemName: "music.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: imageSize, height: imageSize)
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                
                if !showDetails {
                    VStack(alignment: .leading) {
                        if let currentSong = vm.currentSong {
                            Text(currentSong.name)
                            Text(currentSong.artist ?? "Unknown Artist")
                        }
                    }
                    .matchedGeometryEffect(id: "Song Title", in: playAnimation)
                    
                    Spacer()
                    
                    ButtonMusicView(buttonName: vm.isPlayed ? "pause.fill" : "play.fill", size: 25, color: .white) {
                        vm.playPause()
                    }
                }
            }
            .padding()
            .background(showDetails ? .clear : .blue.opacity(0.4))
            .cornerRadius(20)
            .padding()
            
            if showDetails {
                VStack {
                    if let currentSong = vm.currentSong {
                        Text(currentSong.name)
                        Text(currentSong.artist ?? "Unknown")
                    }
                }
                .matchedGeometryEffect(id: "Song Title", in: playAnimation)
                .padding(.horizontal, 30)
                .padding(.top)
                
                VStack {
                    HStack {
                        Text("\(vm.durationFormater(duration: vm.currentTime))")
                        Spacer()
                        Text("\(vm.durationFormater(duration: vm.totalTime))")
                    }
                    .durationFont()
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    
                    Slider(value: $vm.currentTime, in: 0...vm.totalTime) { editing in
                        isDraging = editing
                        if !editing {
                            vm.seekAudio(time: vm.currentTime)
                        }
                    }
                    .padding(.top, -20)
                    .accentColor(.red)
                    
                    HStack(spacing: 50) {
                        ButtonMusicView(buttonName: "backward.end.fill", size: 50, color: .white) {
                            vm.backSong()
                        }
                        
                        ButtonMusicView(buttonName: vm.isPlayed ? "pause.fill" : "play.fill", size: 50, color: .white) {
                            vm.playPause()
                        }
                        
                        ButtonMusicView(buttonName: "forward.end.fill", size: 50, color: .white) {
                            vm.nextSong()
                        }
                    }
                }
                .padding(.horizontal, 30)
            }
        }
    }
}

#Preview {
    MainView()
}
