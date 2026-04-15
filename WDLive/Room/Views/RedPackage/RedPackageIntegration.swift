import UIKit

// Extension to RoomViewController to expose a demo entrypoint for the red package popup.
// Call `showRedPackagePopupDemo()` from RoomViewController (e.g., on a button tap or event) to display.

extension RoomViewController {
    func showRedPackagePopupDemo() {
        let mockGrabbers1 = [
            GrabberInfo(nickname: "QUiugasaasxUOI", giftEmoji: "🍦"),
            GrabberInfo(nickname: "QUiugasaasxUOI", giftEmoji: "👻"),
            GrabberInfo(nickname: "QUiugasaasxUOI", giftEmoji: "🌸")
        ]
        let mockGrabbers2 = [
            GrabberInfo(nickname: "PlayerAlpha", giftEmoji: "🎁"),
            GrabberInfo(nickname: "StarGazer99", giftEmoji: "🎀")
        ]
        let mockGrabbers3 = [
            GrabberInfo(nickname: "LuckyDragon", giftEmoji: "🎉"),
            GrabberInfo(nickname: "NightOwlX", giftEmoji: "🎊"),
            GrabberInfo(nickname: "SilverMoon", giftEmoji: "🌙")
        ]
        let samples: [RedPackageModel] = [
            RedPackageModel(
                nickname: "Loremmmmmmmm...",
                giftEmojis: "🎁 👻",
                value: 20,
                totalCopies: 6,
                isMembersOnly: true,
                grabbedGiftEmoji: "👻",
                grabbedGiftName: "the little heart",
                otherGrabbers: mockGrabbers1
            ),
            RedPackageModel(
                nickname: "PlayerTwo",
                giftEmojis: "🎁 🎀",
                value: 10,
                totalCopies: 3,
                grabbedGiftEmoji: "🎁",
                grabbedGiftName: "the surprise box",
                otherGrabbers: mockGrabbers2
            ),
            RedPackageModel(
                nickname: "Giver",
                giftEmojis: "🎉 🎊",
                value: 5,
                totalCopies: 8,
                grabbedGiftEmoji: "🎉",
                grabbedGiftName: "the party popper",
                otherGrabbers: mockGrabbers3
            )
        ]
        for s in samples { RedPackageManager.shared.enqueue(s) }
        RedPackageManager.shared.show(in: self.view)
    }
}
