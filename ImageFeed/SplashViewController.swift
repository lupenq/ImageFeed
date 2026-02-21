//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Ilia Degtiarev on 24.01.26.
//

import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)

        guard let token = storage.token else {
            return
        }

        fetchProfile(token: token)
    }

    private let storage = OAuth2TokenStorage.shared

    private let profileService = ProfileService.shared

    private let authViewControllerStoryboardId = "AuthViewController"

    private let splashLogoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "splash_screen_logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        view.addSubview(splashLogoImageView)
        NSLayoutConstraint.activate([
            splashLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if storage.token != nil {
            print("User is authorized")
            fetchProfile(token: storage.token ?? "")
        } else {
            print("User is not authorized")
            showAuthScreen()
        }
    }

    private func showAuthScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(
            withIdentifier: authViewControllerStoryboardId
        ) as? AuthViewController else {
            assertionFailure("Failed to instantiate AuthViewController")
            return
        }
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        window.rootViewController = tabBarController
    }

    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()

        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }
            guard let username = profileService.profile?.username else { return }

            switch result {
            case .success:
                ProfileImageService.shared.fetchProfileImageURL(username, token) { _ in }
                self.switchToTabBarController()

            case .failure:
                // TODO: [Sprint 11] Покажите ошибку получения профиля
                break
            }
        }
    }
}
