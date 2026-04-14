//
//  IMConversation.swift
//  WDLive
//

import UIKit

class IMConversation {
    let id: String
    let name: String
    let avatarColor: UIColor
    var messages: [IMMessage]
    var unreadCount: Int

    init(id: String, name: String, avatarColor: UIColor, messages: [IMMessage] = [], unreadCount: Int = 0) {
        self.id = id
        self.name = name
        self.avatarColor = avatarColor
        self.messages = messages
        self.unreadCount = unreadCount
    }

    var lastMessage: IMMessage? { messages.last }

    var lastMessagePreview: String { lastMessage?.previewText ?? "" }

    var lastMessageTime: String {
        guard let msg = lastMessage else { return "" }
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(msg.timestamp) {
            formatter.dateFormat = "HH:mm"
        } else if calendar.isDateInYesterday(msg.timestamp) {
            return "昨天"
        } else {
            formatter.dateFormat = "MM/dd"
        }
        return formatter.string(from: msg.timestamp)
    }
}
