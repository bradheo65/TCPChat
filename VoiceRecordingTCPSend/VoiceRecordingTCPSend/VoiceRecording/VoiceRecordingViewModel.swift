//
//  ContentViewModel.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/09/21.
//

import Foundation

final class VoiceRecordingViewModel: ObservableObject {
    @Published var isActiveServer = false
    @Published var isErrorAlert = false
    
    private let networkManager = NetworkManager()
    private let tcpManager = TCPManager()

    func getIPAddress() -> String? {
        return networkManager.getIPAddress()
    }
    
    func sendText(myIp: String, text: String, ip: String, port: String, completion: @escaping () -> Void) {
        guard let port = Int32(port) else {
            isErrorAlert.toggle()
            return
        }
                
        do {
            let tcpPacket = TCPPacketDTO(ip: myIp, id: text, data: text.data(using: .utf8)!, type: .text)
            //let tcpPacketJson = try JSONEncoder().encode(tcpPacket)
            
            tcpManager.sendTcpData(data: text.data(using: .utf8)!, ip: ip, port: port) { error in
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func sendURL(name: String, url: URL, ip: String, port: String) {
        guard let port = Int32(port) else {
            isErrorAlert.toggle()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let tcpPacket = TCPPacketDTO(ip: ip, id: name, data: data, type: .m4a)
            
            let tcpPacketJson = try JSONEncoder().encode(tcpPacket)
            
            tcpManager.sendTcpData(data: tcpPacketJson, ip: ip, port: port) { error in
                print(error.localizedDescription)
            }
        } catch {
            print(error)
            isErrorAlert.toggle()
        }
    }
    
}
