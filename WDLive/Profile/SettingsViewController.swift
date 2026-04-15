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
    }

    private var cacheSizeText: String = "计算中..."

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设置"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
            }
        }
    }

    private func confirmClearCache() {
        let alert = UIAlertController(title: "清理缓存", message: "确定要清理缓存吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { _ in
            self.clearCache()
        }))
        present(alert, animated: true, completion: nil)
    }

    private func clearCache() {
        let hud = UIAlertController(title: nil, message: "正在清理...", preferredStyle: .alert)
        present(hud, animated: true, completion: nil)
        CacheHelper.shared.clearCache { [weak self] success in
            hud.dismiss(animated: true) {
                guard let self = self else { return }
                let msg = success ? "清理完成" : "清理失败"
                let ok = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                ok.addAction(UIAlertAction(title: "好的", style: .default, handler: { _ in
                    self.fetchCacheSize()
                }))
                self.present(ok, animated: true, completion: nil)
            }
        }
    }
}
