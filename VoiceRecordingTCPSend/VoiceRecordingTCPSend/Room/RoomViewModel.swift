//
//  RoomViewModel.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/09/27.
//

import Foundation

import SwiftSocket

final class RoomViewModel: NSObject, ObservableObject {
    @Published var tcpPacketStore: [TCPPacket] = []
    
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    
    @Published var currentIP = ""
    @Published var targetIP = ""
    @Published var targetPort = ""
    
    private var index = 0
    private let networkManager = NetworkManager()
    
    private var tcpServer: TCPServer? = nil
    
    init(ip: String, port: String) {
        self.targetIP = ip
        self.targetPort = port
    }
    
    func getMessageIndex(index: Int) {
        self.index = index
    }
    
    func startRecordingPlay() {
        tcpPacketStore[index].isPlay = true
    }
    
    func stopRecordingPlay() {
        tcpPacketStore[index].isPlay = false
    }
    
    func startListener() {
        if currentIP.isEmpty {
            showErrorAlert.toggle()
            errorMessage = "Check IP Address"
            return
        }
        guard let port = Int32(targetPort) else {
            showErrorAlert.toggle()
            errorMessage = "Check Port"
            return
        }
        tcpServer = TCPServer(address: currentIP, port: port)
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) {
            switch self.tcpServer?.listen() {
            case .success:
                print("Start Server")
                repeat {
                    if let client = self.tcpServer?.accept(timeout: 1) {
                        if client.address == self.targetIP {
                            DispatchQueue.main.async {
                                self.echoService(client: client) { data in
                                    
                                    
                                    
                                    self.tcpPacketStore.append(data.toDomain())
                                }
                            }
                        }
                    }
                } while self.tcpServer != nil
                
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.showErrorAlert.toggle()
                    self.errorMessage = error.localizedDescription
                }
            case .none:
                break
            }
        }
    }
    
    func stopListener() {
        tcpServer?.close()
        tcpServer = nil
    }
    
    func sendText(text: String, completion: @escaping () -> ()) {
        guard let port = Int32(targetPort) else {
            showErrorAlert.toggle()
            errorMessage = "Check Port"
            return
        }
        
        do {
            let tcpPacket = TCPPacketDTO(
                ip: currentIP,
                id: text,
                data: text.data(using: .utf8)!,
                type: .text
            )
            let tcpPacketJson = try JSONEncoder().encode(tcpPacket)
            
            sendTcpData(data: tcpPacketJson, ip: targetIP, port: port) {
                DispatchQueue.main.async {
                    self.tcpPacketStore.append(tcpPacket.toDomain())
                }
            }
            completion()
        } catch {
            print(error.localizedDescription)
            showErrorAlert.toggle()
            errorMessage = error.localizedDescription
        }
    }
    
    func sendURL(url: URL?) {
        guard let url = url else {
            showErrorAlert.toggle()
            errorMessage = "Check URL"
            return
        }
        guard let port = Int32(targetPort) else {
            showErrorAlert.toggle()
            errorMessage = "Check IP Port"
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let tcpPacket = TCPPacketDTO(
                ip: currentIP,
                id: url.lastPathComponent,
                data: data,
                type: .m4a
            )
            
            let tcpPacketJson = try JSONEncoder().encode(tcpPacket)
            
            sendTcpData(data: tcpPacketJson, ip: targetIP, port: port) {
                tcpPacketStore.append(tcpPacket.toDomain())
            }
        } catch {
            print(error.localizedDescription)
            showErrorAlert.toggle()
            errorMessage = error.localizedDescription
        }
    }
}

extension RoomViewModel {
    
    func getIP() {
        currentIP = networkManager.getIPAddress() ?? ""
    }
    
    private func sendTcpData(data: Data, ip: String, port: Int32, completion: () -> Void) {
        let client = TCPClient(address: ip, port: port)
        let buffer = [UInt8](data)
        
        switch client.connect(timeout: 1) {
        case .success:
            let send = client.send(data: buffer)
            
            switch send {
            case .success:
                print("Send success")
                client.close()
                completion()
            case .failure(let error):
                print(error.localizedDescription)
                showErrorAlert.toggle()
                errorMessage = error.localizedDescription
            }
            
        case .failure(let error):
            print(error.localizedDescription)
            showErrorAlert.toggle()
            errorMessage = error.localizedDescription
        }
    }
    
    private func echoService(client: TCPClient, completion: @escaping (TCPPacketDTO) -> Void) {
        print("Newclient from:\(client.address)[\(client.port)]")
        
        var receivedData = Data()

        if let data = client.read(2048 * 100, timeout: 1) {
            receivedData.append(Data(data))
            let result = client.send(data: data)
            client.close()
            
            switch result {
            case .success:
                print("Response Send success")
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.showErrorAlert.toggle()
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        
        do {
            let tcpPacket = try JSONDecoder().decode(TCPPacketDTO.self, from: receivedData)
            print(tcpPacket)
            
            completion(tcpPacket)
        } catch {
            print(error)
            self.showErrorAlert.toggle()
            self.errorMessage = error.localizedDescription
        }
    }
}
