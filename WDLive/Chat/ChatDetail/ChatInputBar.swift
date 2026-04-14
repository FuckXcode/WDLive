//
//  ChatInputBar.swift
//  WDLive
//

import UIKit

protocol ChatInputBarDelegate: AnyObject {
    func chatInputBar(_ bar: ChatInputBar, didSendText text: String)
    func chatInputBarDidTapImage(_ bar: ChatInputBar)
}

final class ChatInputBar: UIView {

    weak var delegate: ChatInputBarDelegate?

    // MARK: - Subviews

    private let topDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xE5E5EA)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let imageButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        btn.setImage(UIImage(systemName: "photo.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .systemGray
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "发送消息..."
        tf.font = .systemFont(ofSize: 15)
        tf.backgroundColor = UIColor(hex: 0xF2F2F7)
        tf.layer.cornerRadius = 18
        tf.clipsToBounds = true
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.returnKeyType = .send
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("发送", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        btn.tintColor = .systemBlue
        btn.isEnabled = false
        btn.alpha = 0.4
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
}

// MARK: - UI Setup

private extension ChatInputBar {

    func setupViews() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(topDivider)
        addSubview(imageButton)
        addSubview(textField)
        addSubview(sendButton)

        NSLayoutConstraint.activate([
            topDivider.topAnchor.constraint(equalTo: topAnchor),
            topDivider.leadingAnchor.constraint(equalTo: leadingAnchor),
            topDivider.trailingAnchor.constraint(equalTo: trailingAnchor),
            topDivider.heightAnchor.constraint(equalToConstant: 0.5),

            imageButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            imageButton.topAnchor.constraint(equalTo: topAnchor, constant: 9),
            imageButton.widthAnchor.constraint(equalToConstant: 36),
            imageButton.heightAnchor.constraint(equalToConstant: 36),

            textField.leadingAnchor.constraint(equalTo: imageButton.trailingAnchor, constant: 6),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 9),
            textField.heightAnchor.constraint(equalToConstant: 36),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -6),

            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 44)
        ])

        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        imageButton.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }
}

// MARK: - 事件

extension ChatInputBar {

    @objc private func textChanged() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        sendButton.isEnabled = hasText
        sendButton.alpha = hasText ? 1.0 : 0.4
    }

    @objc private func sendTapped() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return }
        delegate?.chatInputBar(self, didSendText: text)
        textField.text = nil
        textChanged()
    }

    @objc private func imageTapped() {
        delegate?.chatInputBarDidTapImage(self)
    }
}

// MARK: - UITextFieldDelegate

extension ChatInputBar: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return false
    }
}
