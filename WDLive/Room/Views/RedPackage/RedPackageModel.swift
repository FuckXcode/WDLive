import Foundation
import UIKit

struct GrabberInfo: Hashable {
    let nickname: String
    let giftEmoji: String
}

struct RedPackageModel: Hashable {
    let id: String
    let avatarURL: String?
    let nickname: String
    let giftEmojis: String
    let value: Int
    let totalCopies: Int
    let isMembersOnly: Bool
    // Result data (shown after user grabs)
    let grabbedGiftEmoji: String
    let grabbedGiftName: String
    let otherGrabbers: [GrabberInfo]

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }

    init(id: String = UUID().uuidString,
         avatarURL: String? = nil,
         nickname: String,
         giftEmojis: String = "🎁 👻",
         value: Int,
         totalCopies: Int = 6,
         isMembersOnly: Bool = false,
         grabbedGiftEmoji: String = "👻",
         grabbedGiftName: String = "the little heart",
         otherGrabbers: [GrabberInfo] = []) {
        self.id = id
        self.avatarURL = avatarURL
        self.nickname = nickname
        self.giftEmojis = giftEmojis
        self.value = value
        self.totalCopies = totalCopies
        self.isMembersOnly = isMembersOnly
        self.grabbedGiftEmoji = grabbedGiftEmoji
        self.grabbedGiftName = grabbedGiftName
        self.otherGrabbers = otherGrabbers
    }
}
