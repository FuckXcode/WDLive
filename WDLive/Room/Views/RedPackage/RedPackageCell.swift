import UIKit
import SnapKit

// MARK: - Cell display state
enum RedPackageCellState { case normal, grabbed, everyoneLuck }

// MARK: - Dashed separator helper
private final class DashedSeparatorView: UIView {
    private let shapeLayer = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        shapeLayer.strokeColor = UIColor(white: 0.6, alpha: 0.7).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [6, 4]
        shapeLayer.fillColor = nil
        layer.addSublayer(shapeLayer)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0.5))
        path.addLine(to: CGPoint(x: bounds.width, y: 0.5))
        shapeLayer.path = path.cgPath
    }
}

// MARK: - RedPackageCell
// swiftlint:disable type_body_length
final class RedPackageCell: UICollectionViewCell {
    static let reuseIdentifier = "RedPackageCell"

    // MARK: Colors
    private static let goldColor     = UIColor(red: 0.93, green: 0.75, blue: 0.30, alpha: 1)
    private static let goldDarkColor = UIColor(red: 0.78, green: 0.56, blue: 0.08, alpha: 1)
    private static let cardRed       = UIColor(red: 0.84, green: 0.13, blue: 0.22, alpha: 1)
    private static let ivory         = UIColor(red: 0.96, green: 0.91, blue: 0.76, alpha: 1)
    private static let darkBrown     = UIColor(red: 0.25, green: 0.18, blue: 0.10, alpha: 1)

    // MARK: Closures (set by PopupView)
    var onGrabTapped: (() -> Void)?
    var onSeeEveryoneLuck: (() -> Void)?
    var onCheckGift: (() -> Void)?

    // MARK: Stored state
    private var currentModel: RedPackageModel?

    // MARK: - Card

    private let cardView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 2
        v.layer.borderColor = RedPackageCell.goldColor.cgColor
        v.clipsToBounds = true
        return v
    }()

    // ─────────────────────────────────────────────────────────────
    // MARK: - Normal container
    // ─────────────────────────────────────────────────────────────

    private let normalContainerView = UIView()

    private let topOrnamentLabel: UILabel = {
        let l = UILabel()
        l.text = "✦  ✦  ✦"
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        l.textColor = RedPackageCell.goldColor
        l.textAlignment = .center
        return l
    }()

    private let avatarRingView: UIView = {
        let v = UIView()
        v.backgroundColor = RedPackageCell.goldColor
        v.layer.cornerRadius = 44
        v.clipsToBounds = true
        return v
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 38
        iv.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: 16)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 2
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.8
        return l
    }()

    private let valueContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 1, alpha: 0.12)
        v.layer.cornerRadius = 14
        return v
    }()

    private let valueTextLabel: UILabel = {
        let l = UILabel()
        l.text = "Value"
        l.font = UIFont.boldSystemFont(ofSize: 14)
        l.textColor = .white
        return l
    }()

    private let diamondLabel: UILabel = {
        let l = UILabel()
        l.text = "💎"
        l.font = UIFont.systemFont(ofSize: 15)
        return l
    }()

    private let valueNumberLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        l.textColor = .white
        return l
    }()

    private let giftEmojisLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 18)
        l.textAlignment = .center
        return l
    }()

    private let grabShadowView: UIView = {
        let v = UIView()
        v.backgroundColor = RedPackageCell.goldDarkColor
        v.layer.cornerRadius = 50
        v.clipsToBounds = true
        return v
    }()

    private let grabButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Grab", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        btn.backgroundColor = RedPackageCell.goldColor
        btn.layer.cornerRadius = 44
        btn.clipsToBounds = true
        return btn
    }()

    private let bottomStripView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.72, green: 0.08, blue: 0.15, alpha: 1)
        return v
    }()

    private let memberInfoLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    // ─────────────────────────────────────────────────────────────
    // MARK: - Result container  (抢到礼物 screen)
    // ─────────────────────────────────────────────────────────────

    private let resultContainerView = UIView()

    private let questionButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("?", for: .normal)
        b.setTitleColor(RedPackageCell.darkBrown, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        b.backgroundColor = UIColor(white: 0.85, alpha: 1)
        b.layer.cornerRadius = 14
        b.clipsToBounds = true
        return b
    }()

    private let resultGiftLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 70)
        l.textAlignment = .center
        return l
    }()

    private let resultTitleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: 17)
        l.textColor = RedPackageCell.darkBrown
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    private let resultSubtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "- Rewards sent to your bag -"
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = UIColor(red: 0.45, green: 0.35, blue: 0.20, alpha: 1)
        l.textAlignment = .center
        return l
    }()

    private let waveDecorLabel: UILabel = {
        let l = UILabel()
        l.text = "〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜"
        l.font = UIFont.systemFont(ofSize: 10)
        l.textColor = RedPackageCell.goldColor
        l.textAlignment = .center
        return l
    }()

    private let seeEveryoneLuckButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("See everyone's luck", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        b.backgroundColor = UIColor(red: 0.32, green: 0.24, blue: 0.14, alpha: 0.85)
        b.layer.cornerRadius = 16
        b.clipsToBounds = true
        return b
    }()

    private let checkGiftButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Check the gift", for: .normal)
        b.setTitleColor(RedPackageCell.darkBrown, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        b.backgroundColor = UIColor(red: 0.98, green: 0.78, blue: 0.12, alpha: 1)
        b.layer.cornerRadius = 24
        b.clipsToBounds = true
        return b
    }()

    // ─────────────────────────────────────────────────────────────
    // MARK: - Lucky list container  (查看其他人抢到的礼物 screen)
    // ─────────────────────────────────────────────────────────────

    private let luckyListContainerView = UIView()

    private let luckyTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "✦  See everyone's luck  ✦"
        l.font = UIFont.boldSystemFont(ofSize: 16)
        l.textColor = RedPackageCell.darkBrown
        l.textAlignment = .center
        return l
    }()

    private let luckyScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let luckyStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        return sv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func commonInit() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { $0.edges.equalToSuperview() }

        setupNormalContainer()
        setupResultContainer()
        setupLuckyListContainer()

        // Only normal visible initially
        resultContainerView.isHidden = true
        luckyListContainerView.isHidden = true
    }

    // MARK: - Setup normal container

    private func setupNormalContainer() {
        normalContainerView.backgroundColor = RedPackageCell.cardRed
        cardView.addSubview(normalContainerView)
        normalContainerView.snp.makeConstraints { $0.edges.equalToSuperview() }

        [topOrnamentLabel, avatarRingView, nameLabel, valueContainerView,
         grabShadowView, grabButton, bottomStripView].forEach { normalContainerView.addSubview($0) }
        avatarRingView.addSubview(avatarImageView)
        [valueTextLabel, diamondLabel, valueNumberLabel, giftEmojisLabel].forEach { valueContainerView.addSubview($0) }
        bottomStripView.addSubview(memberInfoLabel)

        topOrnamentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        avatarRingView.snp.makeConstraints { make in
            make.top.equalTo(topOrnamentLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(88)
        }
        avatarImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(76)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
        }
        valueContainerView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        valueTextLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
        }
        diamondLabel.snp.makeConstraints { make in
            make.left.equalTo(valueTextLabel.snp.right).offset(6)
            make.centerY.equalToSuperview()
        }
        valueNumberLabel.snp.makeConstraints { make in
            make.left.equalTo(diamondLabel.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        giftEmojisLabel.snp.makeConstraints { make in
            make.left.equalTo(valueNumberLabel.snp.right).offset(8)
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        grabShadowView.snp.makeConstraints { make in
            make.top.equalTo(valueContainerView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        grabButton.snp.makeConstraints { make in
            make.center.equalTo(grabShadowView)
            make.width.height.equalTo(88)
        }
        bottomStripView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(grabShadowView.snp.bottom).offset(16)
        }
        memberInfoLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        grabButton.addTarget(self, action: #selector(grabButtonTapped), for: .touchUpInside)
    }

    // MARK: - Setup result container

    private func setupResultContainer() {
        resultContainerView.backgroundColor = RedPackageCell.ivory
        cardView.addSubview(resultContainerView)
        resultContainerView.snp.makeConstraints { $0.edges.equalToSuperview() }

        [questionButton, resultGiftLabel, resultTitleLabel,
         resultSubtitleLabel, waveDecorLabel, seeEveryoneLuckButton, checkGiftButton
        ].forEach { resultContainerView.addSubview($0) }

        questionButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(28)
        }
        resultGiftLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
        }
        resultTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(resultGiftLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        resultSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(resultTitleLabel.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        waveDecorLabel.snp.makeConstraints { make in
            make.top.equalTo(resultSubtitleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        seeEveryoneLuckButton.snp.makeConstraints { make in
            make.top.equalTo(waveDecorLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.65)
            make.height.equalTo(36)
        }
        checkGiftButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(52)
        }

        seeEveryoneLuckButton.addTarget(self, action: #selector(seeEveryoneLuckTapped), for: .touchUpInside)
        checkGiftButton.addTarget(self, action: #selector(checkGiftTapped), for: .touchUpInside)
    }

    // MARK: - Setup lucky list container

    private func setupLuckyListContainer() {
        luckyListContainerView.backgroundColor = RedPackageCell.ivory
        cardView.addSubview(luckyListContainerView)
        luckyListContainerView.snp.makeConstraints { $0.edges.equalToSuperview() }

        luckyListContainerView.addSubview(luckyTitleLabel)
        luckyListContainerView.addSubview(luckyScrollView)
        luckyScrollView.addSubview(luckyStackView)

        luckyTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.right.equalToSuperview().inset(16)
        }
        luckyScrollView.snp.makeConstraints { make in
            make.top.equalTo(luckyTitleLabel.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
        luckyStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(luckyScrollView)
        }
    }

    // MARK: - Button selectors

    @objc private func grabButtonTapped() { onGrabTapped?() }
    @objc private func seeEveryoneLuckTapped() { onSeeEveryoneLuck?() }
    @objc private func checkGiftTapped() { onCheckGift?() }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        nameLabel.text = nil
        valueNumberLabel.text = nil
        giftEmojisLabel.text = nil
        memberInfoLabel.text = nil
        onGrabTapped = nil
        onSeeEveryoneLuck = nil
        onCheckGift = nil
        transitionToState(.normal, animated: false)
    }

    // MARK: - Configure

    func configure(with model: RedPackageModel) {
        currentModel = model
        nameLabel.text = "\(model.nickname)'s gift red bag"
        valueNumberLabel.text = "\(model.value)"
        giftEmojisLabel.text = model.giftEmojis
        let copiesText = model.isMembersOnly
            ? "A total of \(model.totalCopies) copies (members only)"
            : "A total of \(model.totalCopies) copies"
        memberInfoLabel.text = copiesText

        if let urlStr = model.avatarURL, let url = URL(string: urlStr) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                    DispatchQueue.main.async { self.avatarImageView.image = img }
                }
            }
        } else {
            avatarImageView.image = UIImage(named: "default_avatar")
        }
    }

    // MARK: - State transitions (called externally)

    func showGrabbedResult(animated: Bool = true) {
        guard let model = currentModel else { return }
        resultGiftLabel.text = model.grabbedGiftEmoji
        resultTitleLabel.text = "Already grabbed \(model.grabbedGiftName)"
        transitionToState(.grabbed, animated: animated)
    }

    func showEveryoneLuck(animated: Bool = true) {
        guard let model = currentModel else { return }
        rebuildLuckyList(with: model.otherGrabbers)
        transitionToState(.everyoneLuck, animated: animated)
    }

    func resetToNormal(animated: Bool = false) {
        transitionToState(.normal, animated: animated)
    }

    // MARK: - Private helpers

    private func transitionToState(_ state: RedPackageCellState, animated: Bool) {
        let containers = [normalContainerView, resultContainerView, luckyListContainerView]
        let target: UIView
        switch state {
        case .normal:       target = normalContainerView
        case .grabbed:      target = resultContainerView
        case .everyoneLuck: target = luckyListContainerView
        }
        if animated {
            UIView.transition(with: cardView, duration: 0.45, options: [.transitionFlipFromRight]) {
                containers.forEach { $0.isHidden = ($0 !== target) }
            }
        } else {
            containers.forEach { $0.isHidden = ($0 !== target) }
        }
    }

    private func rebuildLuckyList(with grabbers: [GrabberInfo]) {
        luckyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, info) in grabbers.enumerated() {
            let row = makeLuckyRow(nickname: info.nickname, emoji: info.giftEmoji)
            luckyStackView.addArrangedSubview(row)
            if i < grabbers.count - 1 {
                let sep = DashedSeparatorView()
                sep.snp.makeConstraints { $0.height.equalTo(1) }
                luckyStackView.addArrangedSubview(sep)
            }
        }
    }

    private func makeLuckyRow(nickname: String, emoji: String) -> UIView {
        let row = UIView()

        let nicknameLabel = UILabel()
        nicknameLabel.text = nickname
        nicknameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        nicknameLabel.textColor = RedPackageCell.darkBrown
        nicknameLabel.numberOfLines = 1

        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 28)

        row.addSubview(nicknameLabel)
        row.addSubview(emojiLabel)
        row.snp.makeConstraints { $0.height.equalTo(54) }

        nicknameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(emojiLabel.snp.left).offset(-8)
        }
        emojiLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
        }

        return row
    }
}
// swiftlint:enable type_body_length
