//
//  ChatDetailViewController.swift
//  WDLive
//

import UIKit

class ChatDetailViewController: UIViewController {

    private let conversation: IMConversation
    var onMessagesUpdated: (() -> Void)?

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(TextMessageCell.self, forCellReuseIdentifier: TextMessageCell.reuseID)
        tv.register(ImageMessageCell.self, forCellReuseIdentifier: ImageMessageCell.reuseID)
        tv.dataSource = self
        tv.delegate = self
        tv.separatorStyle = .none
        tv.backgroundColor = UIColor(hex: 0xEFEFF4)
        tv.keyboardDismissMode = .interactive
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let inputBar = ChatInputBar()
    private var inputBarBottomConstraint: NSLayoutConstraint!

    // MARK: - Init

    init(conversation: IMConversation) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI

extension ChatDetailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onMessagesUpdated?()
    }

    private func setupUI() {
        title = conversation.name
        view.backgroundColor = UIColor(hex: 0xF7F7F7)
        conversation.unreadCount = 0

        view.addSubview(tableView)
        view.addSubview(inputBar)
        inputBar.delegate = self

        inputBarBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor),

            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBar.heightAnchor.constraint(equalToConstant: 54),
            inputBarBottomConstraint
        ])

        scrollToBottom(animated: false)
    }

    private func scrollToBottom(animated: Bool) {
        guard !conversation.messages.isEmpty else { return }
        let indexPath = IndexPath(row: conversation.messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
}

// MARK: - 键盘处理

extension ChatDetailViewController {

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo,
              let frame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let keyboardHeight = frame.height - view.safeAreaInsets.bottom
        inputBarBottomConstraint.constant = -keyboardHeight
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            self.scrollToBottom(animated: false)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        inputBarBottomConstraint.constant = 0
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
}

// MARK: - 事件

extension ChatDetailViewController {

    private func deleteMessage(at indexPath: IndexPath) {
        conversation.messages.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

    private func appendMessage(_ message: IMMessage) {
        conversation.messages.append(message)
        let indexPath = IndexPath(row: conversation.messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .bottom)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChatDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversation.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = conversation.messages[indexPath.row]
        switch message.type {
        case .text:
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageCell.reuseID, for: indexPath) as! TextMessageCell
            // swiftlint:enable force_cast
            cell.configure(with: message, conversation: conversation)
            return cell
        case .image:
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageMessageCell.reuseID, for: indexPath) as! ImageMessageCell
            // swiftlint:enable force_cast
            cell.configure(with: message, conversation: conversation)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension ChatDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        view.endEditing(true)
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let delete = UIAction(title: "删除", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self?.deleteMessage(at: indexPath)
            }
            return UIMenu(title: "", children: [delete])
        }
    }
}

// MARK: - ChatInputBarDelegate

extension ChatDetailViewController: ChatInputBarDelegate {

    func chatInputBar(_ bar: ChatInputBar, didSendText text: String) {
        let message = IMMessage(
            id: UUID().uuidString,
            type: .text(text),
            sender: .me,
            timestamp: Date()
        )
        appendMessage(message)

        // Simulate auto-reply from the other user
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let replies = ["收到", "好的", "谢谢你的消息~", "我回头看一下", "嘿，马上回复你"]
            let replyText = replies.randomElement() ?? "收到"
            let reply = IMMessage(id: UUID().uuidString, type: .text(replyText), sender: .other, timestamp: Date())
            self.appendMessage(reply)
        }
    }

    func chatInputBarDidTapImage(_ bar: ChatInputBar) {
        let imageColors = ["FF6B6B", "4ECDC4", "45B7D1", "96CEB4", "FFEAA7"]
        let color = imageColors[Int.random(in: 0..<imageColors.count)]
        let message = IMMessage(
            id: UUID().uuidString,
            type: .image(color),
            sender: .me,
            timestamp: Date()
        )
        appendMessage(message)

        // Simulate auto-reply with a small image reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let replyColor = imageColors.randomElement() ?? "4ECDC4"
            let reply = IMMessage(id: UUID().uuidString, type: .image(replyColor), sender: .other, timestamp: Date())
            self.appendMessage(reply)
        }
    }
}
