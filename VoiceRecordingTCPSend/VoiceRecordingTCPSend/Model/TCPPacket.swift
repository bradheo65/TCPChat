//
//  TCPPacket.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/10/04.
//

import Foundation

struct TCPPacket: Codable, Hashable {
    let ip: String
    let id: String
    let data: Data
    let type: PacketType
    
    var isPlay: Bool
}
