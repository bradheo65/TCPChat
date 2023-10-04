//
//  TCPManager.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/09/26.
//

import Foundation

import SwiftSocket

final class TCPManager {
    private var tcpServer: TCPServer? = nil
    
    func sendTcpData(data: Data, ip: String, port: Int32, completion: @escaping (Error) -> Void) {
        let client = TCPClient(address: ip, port: port)
        let buffer = [UInt8](data)
        
        switch client.connect(timeout: 1) {
        case .success:
             let send = client.send(data: buffer)
            
            switch send {
            case .success:
                print("Send success")
                client.close()
            case .failure(let error):
                print(error.localizedDescription)
                completion(error)
            }
            
        case .failure(let error):
            completion(error)
            print(error)
        }
    }
    
    func startServer(ip: String, targetIP: String, port: String, completion: @escaping (TCPPacketDTO) -> Void) {
        guard let port = Int32(port) else {
            return
        }
        tcpServer = TCPServer(address: ip, port: port)

        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) {
            switch self.tcpServer?.listen() {
            case .success:
                print("Start Server")
                repeat {
                    if let client = self.tcpServer?.accept(timeout: 1) {
                        
                        if client.address == targetIP {
                            self.echoService(client: client) { data in
                                completion(data)
                            }
                        }
                        
                    }
                } while self.tcpServer != nil
                
            case .failure(let error):
                print(error.localizedDescription)
            case .none:
                break
            }
        }
    }
    
    func stopServer(ip: String, port: String) {
        tcpServer?.close()
        tcpServer = nil
    }
        
    func echoService(client: TCPClient, completion: @escaping (TCPPacketDTO) -> Void) {
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
            }
        }
        
        do {
            let tcpPacket = try JSONDecoder().decode(TCPPacketDTO.self, from: receivedData)
            print(tcpPacket)
            
            completion(tcpPacket)
        } catch {
            print(error)
        }
        print("Read End")
    }
}
