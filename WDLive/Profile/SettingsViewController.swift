//
//  SettingsViewController.swift
//  WDLive
//

import UIKit

final class SettingsViewController: UITableViewController {

    private enum Section: Int, CaseIterable {
        case general
    }

    private enum GeneralRow: Int, CaseIterable {
        case clearCache
        case about
        case version
        case feedback
    }

    private var cacheSizeText: String = "计算中..."

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设置"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "rightDetail")
        fetchCacheSize()
    }

    private func fetchCacheSize() {
        CacheHelper.shared.calculateCacheSize { [weak self] size in
            guard let self = self else { return }
            self.cacheSizeText = CacheHelper.shared.humanReadableSize(size)
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .general: return GeneralRow.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .general: return "通用"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .none
        cell.selectionStyle = .default
        cell.textLabel?.font = .systemFont(ofSize: 15)
        cell.detailTextLabel?.font = .systemFont(ofSize: 13)
        cell.detailTextLabel?.textColor = .secondaryLabel
        switch Section(rawValue: indexPath.section)! {
        case .general:
            switch GeneralRow(rawValue: indexPath.row)! {
            case .clearCache:
                cell.textLabel?.text = "清理缓存"
                cell.detailTextLabel?.text = cacheSizeText
                cell.accessoryType = .none
                cell.selectionStyle = .default
            case .about:
                cell.textLabel?.text = "关于"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .disclosureIndicator
            case .version:
                cell.textLabel?.text = "版本号"
                if let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    cell.detailTextLabel?.text = ver
                } else {
                    cell.detailTextLabel?.text = "1.0"
                }
                cell.accessoryType = .none
            case .feedback:
                cell.textLabel?.text = "反馈"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .disclosureIndicator
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Section(rawValue: indexPath.section)! {
        case .general:
            switch GeneralRow(rawValue: indexPath.row)! {
            case .clearCache:
                confirmClearCache()
            case .about:
                showAbout()
            case .version:
                break
            case .feedback:
                showFeedback()
            }
        }
    }

    private func showAbout() {
        let about = "WDLive 是一个演示直播 App，包含播放、聊天与礼物动画示例。"
        let vc = UIAlertController(title: "关于 WDLive", message: about, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(vc, animated: true, completion: nil)
    }

    private func showFeedback() {
        let vc = UIAlertController(title: "反馈", message: "请通过发送邮件到 support@example.com 提交反馈。", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(vc, animated: true, completion: nil)
    }

    private func confirmClearCache() {
        let alert = UIAlertController(title: "清理缓存", message: "确定要清理缓存吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { _ in
            self.clearCacheWithSpinner()
        }))
        present(alert, animated: true, completion: nil)
    }

    private func clearCacheWithSpinner() {
        // Show non-blocking spinner overlay
        let spinnerVC = UIAlertController(title: nil, message: "正在清理...\n\n", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        spinnerVC.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: spinnerVC.view.centerXAnchor),
            indicator.bottomAnchor.constraint(equalTo: spinnerVC.view.bottomAnchor, constant: -20)
        ])
        indicator.startAnimating()
        present(spinnerVC, animated: true, completion: nil)

        CacheHelper.shared.clearCache { [weak self] success in
            spinnerVC.dismiss(animated: true) {
                guard let self = self else { return }
                let msg = success ? "清理完成" : "清理失败"
                self.showTransientToast(message: msg)
                self.fetchCacheSize()
            }
        }
    }

    private func showTransientToast(message: String) {
        let toast = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(toast, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                toast.dismiss(animated: true, completion: nil)
            }
        }
    }
}
