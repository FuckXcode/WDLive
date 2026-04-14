//
//  ImageMessageCell.swift
//  WDLive
//

import UIKit

final class ImageMessageCell: UITableViewCell {

    static let reuseID = "ImageMessageCell"

    private static let avatarSize: CGFloat = 32
    private static let imageSize = CGSize(width: 120, height: 90)

    // MARK: - Subviews

    private let avatarView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = ImageMessageCell.avatarSize / 2
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarInitialLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let imageBubble: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let photoIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo.fill")
        iv.tintColor = .white.withAlphaComponent(0.8)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Constraints

    private var avatarLeadingConstraint: NSLayoutConstraint!
    private var avatarTrailingConstraint: NSLayoutConstraint!
    private var bubbleLeadingConstraint: NSLayoutConstraint!
    private var bubbleTrailingConstraint: NSLayoutConstraint!

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Configure

    func configure(with message: IMMessage, conversation: IMConversation) {
        guard case .image(let colorHex) = message.type else { return }
        let hexValue = UInt32(colorHex, radix: 16) ?? 0x4ECDC4
        imageBubble.backgroundColor = UIColor(hex: hexValue)

        let isMe = message.sender == .me
        avatarView.isHidden = isMe
        avatarInitialLabel.text = String(conversation.name.prefix(1))
        avatarView.backgroundColor = conversation.avatarColor

        // Add subtle green border for other user's image messages
        if isMe {
            imageBubble.layer.borderWidth = 0
        } else {
            imageBubble.layer.borderWidth = 2
            imageBubble.layer.borderColor = UIColor(hex: 0xDFF7E0).cgColor
        }

        avatarLeadingConstraint.isActive = !isMe
        avatarTrailingConstraint.isActive = isMe
        bubbleLeadingConstraint.isActive = !isMe
        bubbleTrailingConstraint.isActive = isMe
    }
}

// MARK: - UI Setup

private extension ImageMessageCell {

    func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none

        avatarView.addSubview(avatarInitialLabel)
        imageBubble.addSubview(photoIconView)
        contentView.addSubview(avatarView)
        contentView.addSubview(imageBubble)

        let avSize = ImageMessageCell.avatarSize
        let imgSize = ImageMessageCell.imageSize

        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarView.widthAnchor.constraint(equalToConstant: avSize),
            avatarView.heightAnchor.constraint(equalToConstant: avSize),

            avatarInitialLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarInitialLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            imageBubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageBubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            imageBubble.widthAnchor.constraint(equalToConstant: imgSize.width),
            imageBubble.heightAnchor.constraint(equalToConstant: imgSize.height),

            photoIconView.centerXAnchor.constraint(equalTo: imageBubble.centerXAnchor),
            photoIconView.centerYAnchor.constraint(equalTo: imageBubble.centerYAnchor),
            photoIconView.widthAnchor.constraint(equalToConstant: 32),
            photoIconView.heightAnchor.constraint(equalToConstant: 32)
        ])

        avatarLeadingConstraint = avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        avatarTrailingConstraint = avatarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        bubbleLeadingConstraint = imageBubble.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8)
        bubbleTrailingConstraint = imageBubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
    }
}
