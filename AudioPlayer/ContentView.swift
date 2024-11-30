//
//  ContentView.swift
//  AudioPlayer
//
//  Created by Mehmet Jiyan Atalay on 18.11.2024.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    var fileName: String? = "Sample2"
    var url: URL? = Bundle.main.url(forResource: "Sample2", withExtension: "mp3")
    
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var totalTime: TimeInterval = 0.0
    @State private var currentTime: TimeInterval = 0.0
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Start Playing")
                if let player = player {
                    Text(fileName ?? "File")
                    
                    HStack {
                        Button {
                            isPlaying.toggle()
                            
                            if isPlaying {
                                player.play()
                            } else {
                                player.stop()
                            }
                        } label: {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.largeTitle)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Slider(value: Binding(get: {
                            currentTime
                        }, set: { newValue in
                            player.currentTime = newValue
                            currentTime = newValue
                        }), in: 0...totalTime)
                    }
                    
                    HStack {
                        Text("\(formatTime(currentTime))")
                        Spacer()
                        Text("\(formatTime(totalTime))")
                    }
                    .padding(.horizontal)
                    
                    NavigationLink {
                        AudioRecorderView()
                    } label: {
                        Text("Audio Record")
                    }
                    
                }
            }
        }
        .onAppear {
            if let url {
                setupAudio(withURL: url)
            }
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
        .onDisappear {
            player?.stop()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let seconds = Int(time) % 60
        let minutes = Int(time) / 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func setupAudio(withURL url: URL) {
        do {
            //print("Dosya URL'si: \(url)")
            //print("Dosya mevcut mu: \(FileManager.default.fileExists(atPath: url.path))")
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            totalTime = player?.duration ?? 0.0
        } catch {
            print("Ses yükleme hatası: \(error)")
            print("Hata kodu: \(error._code)")
        }
    }

    private func updateProgress() {
        guard let player = player, player.isPlaying else { return }
        currentTime = player.currentTime
    }
}

#Preview {
    ContentView()
}
