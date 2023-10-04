//
//  AudioRecorderManager.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/09/21.
//

import Foundation
import AVFoundation

final class AudioRecorderManager: NSObject, ObservableObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    // 음성메모 녹음
    var audioRecorder: AVAudioRecorder = AVAudioRecorder()
    @Published var isRecording = false
    
    // 음성메모 재생
    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var isPaused = false
    
    // 음성데이터
    @Published var recordedFiles = [URL]()
    @Published var recordedFile: URL? = nil
    @Published var playEndTime = 0.0

}

extension AudioRecorderManager {
    
    func startRecording() {
        let date = Date()
        let fileURL = getDocumentsDirectory().appendingPathComponent("recording-\(date).m4a")
        
        let setting = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        } catch {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: setting)
            audioRecorder.delegate = self
            audioRecorder.record()
            self.isRecording = true
        } catch {
            print("녹음 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        self.recordedFiles.append(self.audioRecorder.url)
        self.recordedFile = audioRecorder.url
        self.isRecording = false
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

extension AudioRecorderManager {
    func startPlaying(recordingURL: URL) {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: recordingURL)
            
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            
            self.isPlaying = true
            self.isPaused = false
        } catch {
            print("재생 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    func startPlayingData(data: Data) {
        print("Start Playing")
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try audioPlayer = AVAudioPlayer(data: data)
            
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            playEndTime = round((audioPlayer?.duration)! * 10) / 10
            print(round((audioPlayer?.duration)! * 10) / 10)
            
            self.isPlaying = true
            self.isPaused = false
        } catch {
            print("재생 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        self.isPaused = true
    }
    
    func pausePlaying() {
        audioPlayer?.pause()
        self.isPaused = true
    }
    
    func resumePlaying() {
        audioPlayer?.play()
        self.isPaused = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.isPlaying = false
        self.isPaused = false
        
        print("audioPlayerDidFinishPlaying")
    }
    
}
