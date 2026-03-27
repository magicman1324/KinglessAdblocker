import UIKit
import NetworkExtension

class ViewController: UIViewController {

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("启动广告拦截", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStatus()
        toggleButton.addTarget(self, action: #selector(toggleAdblock), for: .touchUpInside)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(extensionStatusChanged),
            name: .NEVPNConfigurationChange,
            object: nil
        )
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Kingless Adblocker"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "全网广告拦截，无痕浏览"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center

        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(statusLabel)
        view.addSubview(toggleButton)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            statusLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 60),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            toggleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 40),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: 20)
        ])
    }

    @objc private func toggleAdblock() {
        loadingIndicator.startAnimating()
        toggleButton.isEnabled = false

        NEFilterManager.shared().loadFromPreferences { loadError in
            DispatchQueue.main.async {
                if let error = loadError {
                    self.showError("加载配置失败: \(error.localizedDescription)")
                    self.loadingIndicator.stopAnimating()
                    self.toggleButton.isEnabled = true
                    return
                }

                let isEnabled = NEFilterManager.shared().isEnabled

                if isEnabled {
                    // 停止过滤器
                    NEFilterManager.shared().isEnabled = false
                    NEFilterManager.shared().saveToPreferences { saveError in
                        DispatchQueue.main.async {
                            if let error = saveError {
                                self.showError("停止失败: \(error.localizedDescription)")
                            } else {
                                self.updateStatus()
                            }
                            self.loadingIndicator.stopAnimating()
                            self.toggleButton.isEnabled = true
                        }
                    }
                } else {
                    // 启动过滤器
                    let filterSettings = NEFilterSettings(rules: [])
                    NEFilterManager.shared().filterSettings = filterSettings
                    NEFilterManager.shared().localizedDescription = "Kingless Adblocker"
                    NEFilterManager.shared().providerConfiguration = NEFilterProviderConfiguration()

                    NEFilterManager.shared().isEnabled = true
                    NEFilterManager.shared().saveToPreferences { saveError in
                        DispatchQueue.main.async {
                            if let error = saveError {
                                self.showError("启动失败: \(error.localizedDescription)")
                            } else {
                                self.updateStatus()
                            }
                            self.loadingIndicator.stopAnimating()
                            self.toggleButton.isEnabled = true
                        }
                    }
                }
            }
        }
    }

    private func updateStatus() {
        NEFilterManager.shared().loadFromPreferences { error in
            DispatchQueue.main.async {
                let isEnabled = NEFilterManager.shared().isEnabled

                if isEnabled {
                    self.statusLabel.text = "✅ 广告拦截已启用\n\n正在拦截全网广告，保护您的隐私"
                    self.statusLabel.textColor = .systemGreen
                    self.toggleButton.setTitle("停止广告拦截", for: .normal)
                    self.toggleButton.backgroundColor = .systemRed
                } else {
                    self.statusLabel.text = "⚠️ 广告拦截未启用\n\n点击下方按钮启用广告拦截功能"
                    self.statusLabel.textColor = .systemOrange
                    self.toggleButton.setTitle("启动广告拦截", for: .normal)
                    self.toggleButton.backgroundColor = .systemBlue
                }
            }
        }
    }

    @objc private func extensionStatusChanged() {
        updateStatus()
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}