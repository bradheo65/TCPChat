//
//  RoomView.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/09/25.
//

import SwiftUI

struct RoomView: View {
    @StateObject private var viewModel: RoomViewModel
    @StateObject private var audioRecorderManager = AudioRecorderManager()
    
    init(
        ip: String,
        port: String
    ) {
        self._viewModel = StateObject(
            wrappedValue: RoomViewModel(
                ip: ip,
                port: port
            )
        )
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.tcpPacketStore, id: \.self) { element in
                    LazyVStack {
                        if element.ip == viewModel.currentIP {
                            HStack {
                                Spacer()
                                
                                if element.type == .m4a {
                                    VoiceRecorderView(
                                        viewModel: viewModel,
                                        audioRecorderManager: audioRecorderManager,
                                        element: element
                                    )
                                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                                    .frame(maxWidth: 300)
                                    .foregroundColor(.white)
                                    .background(.blue)
                                    .cornerRadius(16)
                                } else {
                                    Text("\(element.id)")
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(.blue)
                                        .cornerRadius(16)
                                }
                            }
                        } else {
                            HStack {
                                if element.type == .m4a {
                                    VoiceRecorderView(
                                        viewModel: viewModel,
                                        audioRecorderManager: audioRecorderManager,
                                        element: element
                                    )
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                    .frame(maxWidth: 300)
                                    .background(.white)
                                    .cornerRadius(16)
                                } else {
                                    Text("\(element.id)")
                                        .padding()
                                        .background(.white)
                                        .cornerRadius(16)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .rotationEffect(Angle(degrees: 180))
                .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
            }
            .rotationEffect(Angle(degrees: 180))
            .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
            
            Spacer()
            
            MessageSendView(
                viewModel: viewModel,
                audioRecorderManager: audioRecorderManager
            )
        }
        .showErrorMessage(showAlert: $viewModel.showErrorAlert, message: viewModel.errorMessage)
        .background(Color(uiColor: .secondarySystemBackground))
        .navigationTitle("\(viewModel.targetIP): \(viewModel.targetPort)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.getIP()
            viewModel.startListener()
        }
        .onDisappear {
            viewModel.stopListener()
        }
    }
}

#Preview {
    LoginView()
}

fileprivate struct MessageSendView: View {
    @ObservedObject var viewModel: RoomViewModel
    @ObservedObject var audioRecorderManager: AudioRecorderManager
    
    @State private var text = ""
    
    fileprivate init(
        viewModel: RoomViewModel,
        audioRecorderManager: AudioRecorderManager
    ) {
        self.viewModel = viewModel
        self.audioRecorderManager = audioRecorderManager
    }
    
    fileprivate var body: some View {
        HStack {
            Button {
                audioRecorderManager.isRecording
                ? audioRecorderManager.stopRecording()
                : audioRecorderManager.startRecording()
            } label: {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 25))
                    .foregroundColor(
                        audioRecorderManager.isRecording
                        ? .red
                        : .blue
                    )
            }
            
            TextField("Text", text: $text)
                .background(Color(uiColor: .systemBackground))
            
            Button("Send") {
                viewModel.sendText(
                    text: text
                ) {
                    text = ""
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(text.isEmpty)
        }
        .padding()
        .background(.white)
        .onChange(of: audioRecorderManager.isRecording, perform: { value in
            if value == false {
                viewModel.sendURL(url: audioRecorderManager.recordedFile)
            }
        })
    }
}

fileprivate struct VoiceRecorderView: View {
    @ObservedObject var viewModel: RoomViewModel
    @ObservedObject var audioRecorderManager: AudioRecorderManager
    
    @State var element: TCPPacket
    
    @State private var downloadAmount = 0.0
    @State private var timer: Timer?
    
    fileprivate init(
        viewModel: RoomViewModel,
        audioRecorderManager: AudioRecorderManager,
        element: TCPPacket
    ) {
        self.viewModel = viewModel
        self.audioRecorderManager = audioRecorderManager
        self.element = element
    }
    
    fileprivate var body: some View {
        VStack {
            HStack {
                Image(systemName: element.isPlay ? "pause.circle" : "play.circle.fill")
                    .font(.system(size: 40))
                    .onTapGesture {
                        if let index = viewModel.tcpPacketStore.firstIndex(where: {$0.id == element.id}) {
                            viewModel.getMessageIndex(index: index)
                        }
                        audioRecorderManager.startPlayingData(data: element.data)
                        viewModel.startRecordingPlay()
                    }
                Text("\(element.id)")
                    .padding()
            }
            if element.isPlay {
                ProgressView(
                    value: downloadAmount,
                    total: audioRecorderManager.playEndTime.formatter * 100
                )
                .padding()
                .onAppear {
                    timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                        if downloadAmount.formatter < audioRecorderManager.playEndTime.formatter * 100 {
                            downloadAmount += 1
                        } else {
                            viewModel.stopRecordingPlay()
                            timer?.invalidate()
                        }
                    })
                }
            }
        }
    }
}

