//
//  LoginViewModel.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/10/04.
//

import Foundation

final class LoginViewModel: ObservableObject {
    
    @Published var currentIP = ""
    private let networkManager = NetworkManager()
    
    init() {
        getCurrentIP()
    }
    
    func getCurrentIP() {
        currentIP = networkManager.getIPAddress() ?? ""
    }
    
}
