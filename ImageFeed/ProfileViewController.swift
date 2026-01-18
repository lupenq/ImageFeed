//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Ilia Degtiarev on 17.01.26.
//

import UIKit

class ProfileViewController: UIViewController {
    var imageView: UIImageView!
    var fullNameLabel: UILabel!
    var loginLabel: UILabel!
    var descriptionLabel: UILabel!
    var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        renderUserpic()
        renderFullName()
        renderLoginLabel()
        renderDescriptionLabel()
        renderLogoutButton()
    }

    func renderUserpic() {
        let profileImage = UIImage(named: "UserPic")

        imageView = UIImageView(image: profileImage)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }

    func renderFullName() {
        fullNameLabel = UILabel()

        fullNameLabel.text = "Екатерина Новикова"
        fullNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        fullNameLabel.textColor = UIColor(named: "YP White")

        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(fullNameLabel)

        fullNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        fullNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
    }

    func renderLoginLabel() {
        loginLabel = UILabel()

        loginLabel.text = "@ekaterina_nov"
        loginLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginLabel.textColor = UIColor(named: "YP Gray")

        loginLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(loginLabel)

        loginLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor).isActive = true
        loginLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8).isActive = true
    }

    func renderDescriptionLabel() {
        descriptionLabel = UILabel()

        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.numberOfLines = 0

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(descriptionLabel)

        descriptionLabel.leadingAnchor.constraint(equalTo: loginLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8).isActive = true
    }

    func renderLogoutButton() {
        logoutButton = UIButton(type: .system)

        logoutButton.setImage(UIImage(named: "Logout Icon"), for: .normal)

        logoutButton.tintColor = .red

        logoutButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(logoutButton)

        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
}
