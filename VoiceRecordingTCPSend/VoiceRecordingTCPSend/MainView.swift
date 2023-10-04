//
//  MainView.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/09/22.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            VoiceRecordingView()
                .tabItem {
                    Image(systemName: "recordingtape")
                    Text("Recording")
                }
            
            TCPServerView()
                .tabItem {
                    Image(systemName: "network")
                    Text("Server")
                }
            
            LoginView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Room")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
