import UIKit
import SnapKit

protocol RedPackagePopupDelegate: AnyObject {
    func redPackagePopupDidDismiss()
}

final class RedPackagePopupView: UIView {
    private let dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0, alpha: 0.6)
        v.alpha = 0
        return v
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }()

    private let layout = RedPackageLayout()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.decelerationRate = .fast
        cv.register(RedPackageCell.self, forCellWithReuseIdentifier: RedPackageCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("✕", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        b.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        b.layer.cornerRadius = 22
        b.clipsToBounds = true
        return b
    }()

    private var models: [RedPackageModel] = []
    /// Persist cell states across scroll/reuse
    private var cellStates: [String: RedPackageCellState] = [:]
    weak var delegate: RedPackagePopupDelegate?

    init(models: [RedPackageModel]) {
        self.models = models
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func commonInit() {
        addSubview(dimView)
        addSubview(containerView)
        containerView.addSubview(collectionView)
        containerView.addSubview(closeButton)

        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }

        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.65)
        }

        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.82)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(44)
        }

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(tap)
    }

    @objc private func dimTapped() { hide() }
    @objc private func closeTapped() { hide() }

    func show(in parent: UIView) {
        frame = parent.bounds
        parent.addSubview(self)
        layoutIfNeeded()
        collectionView.reloadData()
        applyScales(animated: false)
        UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.dimView.alpha = 1
        }
    }

    func hide() {
        delegate?.redPackagePopupDidDismiss()
        UIView.animate(withDuration: 0.2, animations: {
            self.dimView.alpha = 0
        }) { _ in self.removeFromSuperview() }
    }

    // MARK: - Scale helpers

    private func applyScales(animated: Bool) {
        let visibleCenterX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let maxDistance = layout.itemSize.width + layout.spacing
        let minScale: CGFloat = 0.85
        for cell in collectionView.visibleCells.compactMap({ $0 as? RedPackageCell }) {
            let distance = abs(cell.frame.midX - visibleCenterX)
            let normalized = min(distance / maxDistance, 1.0)
            let scale = 1.0 - (1.0 - minScale) * normalized
            if animated {
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
                    cell.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            } else {
                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension RedPackagePopupView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RedPackageCell.reuseIdentifier, for: indexPath
        ) as? RedPackageCell else { return UICollectionViewCell() }

        let model = models[indexPath.item]
        cell.configure(with: model)
        setupCellClosures(cell: cell, model: model)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let packageCell = cell as? RedPackageCell else { return }

        // Restore persisted state (no animation — cell is about to appear)
        let model = models[indexPath.item]
        switch cellStates[model.id] ?? .normal {
        case .normal:       break
        case .grabbed:      packageCell.showGrabbedResult(animated: false)
        case .everyoneLuck: packageCell.showEveryoneLuck(animated: false)
        }

        // Initial scale
        let visibleCenterX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let maxDistance = layout.itemSize.width + layout.spacing
        let minScale: CGFloat = 0.85
        let distance = abs(packageCell.frame.midX - visibleCenterX)
        let normalized = min(distance / maxDistance, 1.0)
        packageCell.transform = CGAffineTransform(scaleX: 1.0 - (1.0 - minScale) * normalized, y: 1.0 - (1.0 - minScale) * normalized)
    }

    // MARK: Scroll

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        applyScales(animated: false)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        applyScales(animated: true)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { applyScales(animated: true) }
    }

    // MARK: - Private closure wiring

    private func setupCellClosures(cell: RedPackageCell, model: RedPackageModel) {
        cell.onGrabTapped = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.cellStates[model.id] = .grabbed
            cell.showGrabbedResult(animated: true)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        cell.onSeeEveryoneLuck = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.cellStates[model.id] = .everyoneLuck
            cell.showEveryoneLuck(animated: true)
        }
        cell.onCheckGift = { [weak self] in
            self?.hide()
        }
    }
}
