import UIKit

final class RedPackageManager {
    static let shared = RedPackageManager()
    private init() {}

    private var queue: [RedPackageModel] = []
    private var popup: RedPackagePopupView?

    func enqueue(_ model: RedPackageModel) {
        if queue.contains(where: { $0.id == model.id }) { return }
        queue.append(model)
    }

    func show(in parent: UIView) {
        guard !queue.isEmpty else { return }
        popup = RedPackagePopupView(models: queue)
        popup?.show(in: parent)
    }

    func clear() {
        queue.removeAll()
        popup?.hide()
        popup = nil
    }
}
