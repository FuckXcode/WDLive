//
//  IMMockData.swift
//  WDLive
//

import UIKit

final class IMMockData {

    static let shared = IMMockData()
    var conversations: [IMConversation] = []

    private init() {
        conversations = buildConversations()
    }

    // MARK: - Build mock conversations

    private func buildConversations() -> [IMConversation] {
        let users: [(name: String, color: UIColor)] = [
            ("小红", UIColor(hex: 0xFF4D6D)),
            ("张伟", UIColor(hex: 0x4D79FF)),
            ("李娜", UIColor(hex: 0xFF9900)),
            ("王者", UIColor(hex: 0x33CC66)),
            ("陈晨", UIColor(hex: 0xAA55FF))
        ]

        return users.enumerated().map { index, user in
            let conv = IMConversation(
                id: "conv_\(index)",
                name: user.name,
                avatarColor: user.color,
                messages: buildMessages(for: user.name),
                unreadCount: index == 0 ? 3 : (index == 2 ? 1 : 0)
            )
            return conv
        }
    }

    // swiftlint:disable function_body_length
    private func buildMessages(for name: String) -> [IMMessage] {
        let now = Date()
        func date(_ minutesAgo: Double) -> Date { now.addingTimeInterval(-minutesAgo * 60) }

        let imageColors = ["FF6B6B", "4ECDC4", "45B7D1", "96CEB4", "FFEAA7"]

        let dialogues: [(text: String, sender: IMMessageSender, minutesAgo: Double)] = [
            ("你好！在吗？", .other, 120),
            ("在的，怎么了？", .me, 119),
            ("最近直播间看到你，感觉你唱歌好好听！", .other, 118),
            ("哈哈谢谢，还在练习中", .me, 117),
            ("什么时候再开播？", .other, 60),
            ("今晚八点，记得来捧场", .me, 59),
            ("好的，一定来！送你个大火箭", .other, 58),
            ("哈哈哈 谢谢", .me, 57),
            ("期待你的演出！", .other, 30),
            ("感谢支持，有你们真好", .me, 10),
            ("下次见~", .other, 5),
            ("下次见！", .me, 2)
        ]

        return dialogues.enumerated().map { index, item in
            // Insert image messages at positions 3 and 8
            if index == 3 {
                return IMMessage(
                    id: "\(name)_\(index)",
                    type: .image(imageColors[0]),
                    sender: .me,
                    timestamp: date(item.minutesAgo + 0.5)
                )
            } else if index == 8 {
                return IMMessage(
                    id: "\(name)_\(index)",
                    type: .image(imageColors[1]),
                    sender: .other,
                    timestamp: date(item.minutesAgo + 0.5)
                )
            }
            return IMMessage(
                id: "\(name)_\(index)",
                type: .text(item.text),
                sender: item.sender,
                timestamp: date(item.minutesAgo)
            )
        }
    }
    // swiftlint:enable function_body_length
}
