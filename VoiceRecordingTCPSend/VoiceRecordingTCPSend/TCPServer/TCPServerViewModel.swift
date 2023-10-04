//
//  TCPServerViewModel.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/09/22.
//

import Foundation

import SwiftSocket

final class TCPServerViewModel: ObservableObject {
    @Published var voiceMemoStore: [TCPPacketDTO] = []
    @Published var isActiveListener = false
    @Published var isErrorAlert = false

    private let networkManager = NetworkManager()
    private let audioRecorderManager = AudioRecorderManager()
    
    func getIPAddress() -> String? {
        return networkManager.getIPAddress()
    }
    
    func startServer(ip: String, port: String) {
        guard let port = Int32(port) else {
            isErrorAlert.toggle()
            return
        }
                
        let server = TCPServer(address: ip, port: port)
        isActiveListener = true

        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) {
            switch server.listen() {
            case .success:
                print("Start Server")
                repeat {
                    if let client = server.accept(timeout: 1) {
                        
                        self.echoService(client: client)
                    } else {
                        print("accept error")
                    }
                } while true
                
                self.isActiveListener = false
            case .failure(let error):
                self.isActiveListener = false
                self.isErrorAlert.toggle()
                print(error.localizedDescription)
            }
        }
    }
    
    func echoService(client: TCPClient) {
        print("Newclient from:\(client.address)[\(client.port)]")

        var receivedData = Data()
        var timeoutCounter = 0
        
        if let data = client.read(1024, timeout: 1) {
            if data.isEmpty {
                timeoutCounter += 1
                if timeoutCounter >= 2 {
                    // 데이터 수신 종료 조건을 만족하면 루프 종료
                }
            } else {
                timeoutCounter = 0
                receivedData.append(Data(data))
            }
        }
        
        do {
            let tcpPacket = try JSONDecoder().decode(TCPPacketDTO.self, from: receivedData)
            print(tcpPacket)
            DispatchQueue.main.async {
                self.voiceMemoStore.append(tcpPacket)
            }
            client.close()
        } catch {
            print(error)
        }
        print("Read End")
    }
}
