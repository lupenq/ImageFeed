//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Ilia Degtiarev on 24.01.26.
//

import ProgressHUD
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    let segueIdentifier = "ShowWebView"

    private let oauth2Service = OAuth2Service.shared

    private let oauth2TokenStorage = OAuth2TokenStorage.shared

    weak var delegate: AuthViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(segueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Backward") // 1
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Backward") // 2
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 3
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black") // 4
    }

    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()

        oauth2Service.fetchOAuthToken(code, completion: { [weak self] result in
            guard let self = self else { return }

            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success:
                DispatchQueue.main.async {
                    print("Successfully fetched OAuth token")
                    self.oauth2TokenStorage.token = try? result.get()
                    self.delegate?.didAuthenticate(self)
                    print("Token stored: \(String(describing: self.oauth2TokenStorage.token))")
                    vc.dismiss(animated: true)
                }
            case .failure:
                DispatchQueue.main.async {
                    self.showAuthErrorAlert()
                }
            }
        })
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
