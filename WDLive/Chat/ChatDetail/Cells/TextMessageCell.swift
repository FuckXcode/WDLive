//
//  TextMessageCell.swift
//  WDLive
//

import UIKit

final class TextMessageCell: UITableViewCell {

    static let reuseID = "TextMessageCell"

    private static let maxBubbleWidth = UIScreen.main.bounds.width * 0.65
    private static let bubblePadding = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
    private static let avatarSize: CGFloat = 32

    // MARK: - Subviews

    private let avatarView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = TextMessageCell.avatarSize / 2
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

    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Constraints (toggled per sender)

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
        guard case .text(let text) = message.type else { return }
        messageLabel.text = text

        let isMe = message.sender == .me
        bubbleView.backgroundColor = isMe ? .systemBlue : UIColor(hex: 0xE6F7E6)
        messageLabel.textColor = isMe ? .white : .label
        avatarView.isHidden = isMe
        avatarInitialLabel.text = String(conversation.name.prefix(1))
        avatarView.backgroundColor = conversation.avatarColor

        avatarLeadingConstraint.isActive = !isMe
        avatarTrailingConstraint.isActive = isMe
        bubbleLeadingConstraint.isActive = !isMe
        bubbleTrailingConstraint.isActive = isMe
    }
}

// MARK: - UI Setup

private extension TextMessageCell {

    func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none

        avatarView.addSubview(avatarInitialLabel)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(bubbleView)

        let pad = TextMessageCell.bubblePadding
        let maxW = TextMessageCell.maxBubbleWidth
        let avSize = TextMessageCell.avatarSize

        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarView.widthAnchor.constraint(equalToConstant: avSize),
            avatarView.heightAnchor.constraint(equalToConstant: avSize),

            avatarInitialLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarInitialLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: pad.top),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: pad.left),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -pad.right),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -pad.bottom),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: maxW - pad.left - pad.right),

            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        avatarLeadingConstraint = avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        avatarTrailingConstraint = avatarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        bubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8)
        bubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
    }
}
