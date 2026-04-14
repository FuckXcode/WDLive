//
//  ConversationListViewController.swift
//  WDLive
//

import UIKit

class ConversationListViewController: UIViewController {

    private var conversations: [IMConversation] = IMMockData.shared.conversations

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.reuseID)
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = 68
        tv.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
}

// MARK: - UI

extension ConversationListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "私信"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension ConversationListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reuseID, for: indexPath) as! ConversationCell
        // swiftlint:enable force_cast
        cell.configure(with: conversations[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        conversations.remove(at: indexPath.row)
        IMMockData.shared.conversations = conversations
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

// MARK: - UITableViewDelegate

extension ConversationListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = ChatDetailViewController(conversation: conversations[indexPath.row])
        detail.onMessagesUpdated = { [weak self] in
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        // Hide tab bar when pushing chat detail
        detail.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detail, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        "删除"
    }
}
