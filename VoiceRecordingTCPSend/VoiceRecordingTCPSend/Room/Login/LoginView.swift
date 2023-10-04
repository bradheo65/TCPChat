//
//  LoginView.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/09/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    @State private var ip = ""
    @State private var port = ""

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        VStack {
                            HStack {
                                Text("Join Room")
                                    .font(.title)
                                    .bold()
                                
                                Spacer()
                            }
                            .padding(.bottom)
                            
                            HStack {
                                Text("Current IP: \(viewModel.currentIP)")
                                
                                Spacer()
                            }
                            VStack {
                                TextField("IP ", text: $ip)
                                
                                Divider()
                                
                                TextField("port ", text: $port)
                            }
                            .padding()
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(16)
                        }
                        .padding()
                        
                        NavigationLink {
                            RoomView(
                                ip: ip,
                                port: port
                            )
                        } label: {
                            HStack {
                                Spacer()
                                
                                Text("Start Chat")
                                    .font(.system(size: 16, weight: .bold))
                                
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .background(.blue)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .shadow(radius: 15)
                        }
                    }
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                }
                .background(Color(uiColor: .secondarySystemFill))
            }
        }
    }
}

#Preview {
    LoginView()
}
