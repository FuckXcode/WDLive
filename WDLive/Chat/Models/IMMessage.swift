//
//  IMMessage.swift
//  WDLive
//

import UIKit

enum IMMessageType {
    case text(String)
    case image(String) // image color hex for mock
}

enum IMMessageSender {
    case me
    case other
}

class IMMessage {
    let id: String
    let type: IMMessageType
    let sender: IMMessageSender
    let timestamp: Date

    init(id: String, type: IMMessageType, sender: IMMessageSender, timestamp: Date) {
        self.id = id
        self.type = type
        self.sender = sender
        self.timestamp = timestamp
    }

    var previewText: String {
        switch type {
        case .text(let text): return text
        case .image: return "[图片]"
        }
    }
}
