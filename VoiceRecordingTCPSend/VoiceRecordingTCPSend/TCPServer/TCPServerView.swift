//
//  TCPServerView.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/09/21.
//

import SwiftUI

struct TCPServerView: View {
    @StateObject private var viewModel = TCPServerViewModel()
    @StateObject private var audioRecorderManager = AudioRecorderManager()

    @State private var showSetting = false

    @State private var serverIp = ""
    @State private var serverPort = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack {
                        ServerPortSettingView(
                            serverIp: $serverIp,
                            serverPort: $serverPort
                        )
                        
                        Button {
                            viewModel.startServer(
                                ip: serverIp,
                                port: serverPort
                            )
                        } label: {
                            HStack {
                                Spacer()
                                Text(viewModel.isActiveListener ? "Listening" : "Start Listener")
                                    .font(.system(size: 16, weight: .bold))
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .background(viewModel.isActiveListener ? .red : .blue)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .shadow(radius: 15)
                        }
                        
                        VStack {
                            HStack {
                                Text("Receive Data List")
                                    .font(.title2)
                                    .bold()
                                
                                Spacer()
                            }
                            
                            Divider()
                        }
                        .padding()
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }
                    
                    ForEach(viewModel.voiceMemoStore, id: \.id) { element in
                        Button {
                            if element.type == .m4a {
                                audioRecorderManager.startPlayingData(data: element.data)
                            }
                        } label: {
                            Text(element.id)
                        }
                        .padding()
                        .foregroundStyle(audioRecorderManager.isPlaying ? .red : .accentColor)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(16)
                    }
                    .padding([.leading, .trailing])
                }
            }
            .navigationTitle("Listener")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .alert("Error", isPresented: $viewModel.isErrorAlert) {
            Button { } label: {
                Text("OK")
            }
        } message: {
            Text("Check IP or Port")
        }
        .onAppear {
            serverIp = viewModel.getIPAddress() ?? ""
        }
    }
    
}

struct TCPServerView_Previews: PreviewProvider {
    static var previews: some View {
        TCPServerView()
    }
}

fileprivate struct ServerPortSettingView: View {
    @Binding var serverIp: String
    @Binding var serverPort: String
    
    init(serverIp: Binding<String>, serverPort: Binding<String>) {
        self._serverIp = serverIp
        self._serverPort = serverPort
    }
    
    fileprivate var body: some View {
        VStack {
            HStack {
                Text("ServerPort Setting")
                    .font(.title2)
                    .bold()
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Current IP: \(serverIp)")
                    TextField("Port", text: $serverPort)
                        .keyboardType(.numberPad)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(16)
        }
        .padding()
    }
}
