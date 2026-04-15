//
//  ProfileViewController.swift
//  WDLive
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNav()
    }

    private func setupNav() {
        navigationItem.title = "我的"
        let settings = UIBarButtonItem(title: "设置", style: .plain, target: self, action: #selector(onSettings))
        navigationItem.rightBarButtonItem = settings
    }

    @objc private func onSettings() {
        let settingsVC = SettingsViewController(style: .insetGrouped)
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}
