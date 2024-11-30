//
//  AudioRecorderView.swift
//  AudioPlayer
//
//  Created by Mehmet Jiyan Atalay on 30.11.2024.
//

import SwiftUI
import AVFoundation
import AVKit
import SwiftData

struct AudioRecorderView: View {
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioFilename: URL?
    @State private var isRecording = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding()
            
            Button(action: {
                startPlayback()
            }) {
                Text("Play Recording")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .disabled(audioFilename == nil)
            .padding()
        }
    }
    
    private func startRecording() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = documentsDirectory.appendingPathComponent("recording.m4a")
        audioFilename = filename
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
            audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        if let audioFilename = audioFilename {
            saveAudioToDatabase(filePath: audioFilename)
        }
    }
    
    private func startPlayback() {
        guard let filename = audioFilename else { 
            print("Audio filename is nil")
            return 
        }
        
        //print("Playback için dosya yolu: \(filename)")
        //print("Dosya mevcut mu: \(FileManager.default.fileExists(atPath: filename.path))")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: filename)
            audioPlayer?.play()
        } catch {
            print("Failed to start playback: \(error)")
        }
    }
    
    private func saveAudioToDatabase(filePath: URL) {
        let audioRecord = AudioRecord(filePath: filePath.absoluteString)
        
        modelContext.insert(audioRecord)
        
        do {
            try modelContext.save()
            print("Audio file path saved to database: \(filePath.absoluteString)")
        } catch {
            print("Failed to save audio path to database: \(error)")
        }
    }
    
    private func playAudioFromDatabase(record: AudioRecord) {
        guard let audioPath = URL(string: record.filePath) else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioPath)
            audioPlayer?.play()
        } catch {
            print("Failed to play audio from database: \(error)")
        }
    }
}

#Preview {
    AudioRecorderView()
}

@Model
class AudioRecord {
    @Attribute(.unique) var id: UUID
    var filePath: String
    
    init(filePath: String) {
        self.id = UUID()
        self.filePath = filePath
    }
}
