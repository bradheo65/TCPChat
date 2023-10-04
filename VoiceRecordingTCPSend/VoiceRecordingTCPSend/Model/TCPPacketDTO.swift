//
//  TCPPacketDTO.swift
//  VoiceRecordingTCPSend
//
//  Created by brad on 2023/09/27.
//

import Foundation

struct TCPPacketDTO: Codable, Hashable {
    let ip: String
    let id: String
    let data: Data
    let type: PacketType
}

extension TCPPacketDTO {
    func toDomain() -> TCPPacket {
        return .init(
            ip: ip,
            id: id,
            data: data,
            type: type,
            isPlay: false
        )
    }
}
