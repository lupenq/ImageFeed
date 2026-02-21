//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Ilia Degtiarev on 21.02.26.
//

import Foundation

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String

    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    private(set) var avatarURL: String?

    static let shared = ProfileImageService()

    private var task: URLSessionTask?
    private let urlSession = URLSession.shared

    private init() {}

    func fetchProfileImageURL(_ username: String, _ token: String, completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()

        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let profileImageResult):
                let avatarURL = profileImageResult.profileImage.small
                self?.avatarURL = avatarURL
                completion(.success(avatarURL))
                print(avatarURL)
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
            case .failure(let error):
                print("[ProfileImageService fetchProfileImageURL]: failure - \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
        }

        self.task = task
        task.resume()
    }

    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/" + username) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
