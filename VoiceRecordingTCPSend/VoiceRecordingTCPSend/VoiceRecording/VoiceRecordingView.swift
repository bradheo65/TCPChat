//
//  ContentView.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/09/20.
//

import SwiftUI
import AVFoundation

struct VoiceRecordingView: View {
    @StateObject private var audioRecorderManager = AudioRecorderManager()
    @StateObject private var viewModel = VoiceRecordingViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                RecordingListView(
                    audioRecorderManager: audioRecorderManager,
                    viewModel: viewModel
                )    
    
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .navigationTitle("Voice Recording")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Error", isPresented: $viewModel.isErrorAlert) {
            Button { } label: {
                Text("OK")
            }
        } message: {
            Text("Check IP or Port, Active Server Listener Mode")
        }
    }
}

// MARK: - 음성메모 리스트 뷰
private struct RecordingListView: View {
    @ObservedObject private var audioRecorderManager: AudioRecorderManager
    @ObservedObject private var viewModel: VoiceRecordingViewModel

    @State private var showSetting = false

    @State private var currentIP = ""
    @State private var targetServerIP = ""
    @State private var targetServerPort = ""
    
    @State private var message = ""

    fileprivate init(
        audioRecorderManager: AudioRecorderManager,
        viewModel: VoiceRecordingViewModel
    ) {
        self.audioRecorderManager = audioRecorderManager
        self.viewModel = viewModel
    }
    
    fileprivate var body: some View {
        VStack {
            VStack {
                VStack(alignment: .leading) {
                    Text("IP Setting")
                        .font(.title2)
                        .bold()
                    
                    Divider()
                    
                    VStack {
                        Text("Current IP: \(currentIP)")
                        TextField("Server IP", text: $targetServerIP)
                        TextField("Server Port", text: $targetServerPort)
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                }
                .padding()

                VStack(alignment: .leading) {
                    Text("Message")
                        .font(.title2)
                        .bold()
                    
                    Divider()
                    
                    HStack {
                        TextField("Send Mesage", text: $message)
                        
                        Button("Send") {
                            viewModel.sendText(
                                myIp: currentIP,
                                text: message,
                                ip: targetServerIP,
                                port: targetServerPort
                            ) {
                                message = ""
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(message.isEmpty)
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(16)
                }
                .padding()
            }
            .onTapGesture {
                hideKeyboard()
            }

            Button {
                audioRecorderManager.isRecording
                ? audioRecorderManager.stopRecording()
                : audioRecorderManager.startRecording()
                
            } label: {
                HStack {
                    Spacer()
                    Text(audioRecorderManager.isRecording ? "Stop Recording" : "Start Recording")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical)
                .background(audioRecorderManager.isRecording ? Color.red : Color.blue)
                .cornerRadius(16)
                .padding(.horizontal)
                .shadow(radius: 15)
            }
            
            VStack {
                HStack {
                    Text("Recording Voice List")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                }
                                
                Divider()
            }
            .padding([.top, .leading, .trailing])
            
            ForEach(audioRecorderManager.recordedFiles, id: \.self) { recordedFile in
                Button {
                    viewModel.sendURL(
                        name: recordedFile.lastPathComponent,
                        url: recordedFile,
                        ip: targetServerIP,
                        port: targetServerPort
                    )
                } label: {
                    Text(recordedFile.lastPathComponent)
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(16)
            }
            
        }
        .onAppear {
            currentIP = viewModel.getIPAddress() ?? ""
        }
    }
}

struct VoiceRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceRecordingView()
    }
}
