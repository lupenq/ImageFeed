//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Ilia Degtiarev on 07.03.26.
//

import CoreGraphics
import Foundation

private let photosPerPage = 10
private let iso8601Formatter = ISO8601DateFormatter()

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct UserPhotoResult: Decodable {
    let id: String
    let username: String
    let name: String?
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let likes: Int
    let likedByUser: Bool
    let welcomeDescription: String?
    let user: UserPhotoResult
    let urls: UrlsResult

    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width
        case height
        case color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case welcomeDescription = "description"
        case user
        case urls
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

private extension PhotoResult {
    func toPhoto() -> Photo {
        Photo(
            id: id,
            size: CGSize(width: width, height: height),
            createdAt: iso8601Formatter.date(from: createdAt),
            welcomeDescription: welcomeDescription,
            thumbImageURL: urls.thumb,
            largeImageURL: urls.full,
            isLiked: likedByUser
        )
    }
}

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []

    private var lastLoadedPage: Int = 0
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared

    private init() {}

    func fetchPhotosNextPage() {
        guard task == nil else { return }

        let nextPage = lastLoadedPage + 1
        guard let request = makePhotosRequest(page: nextPage) else { return }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { $0.toPhoto() }
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            case .failure(let error):
                print("[ImagesListService fetchPhotosNextPage]: failure - \(error.localizedDescription)")
            }
            self.task = nil
        }

        self.task = task
        task.resume()
    }

    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token,
              var urlComponents = URLComponents(string: "\(Constants.defaultBaseURLString)/photos")
        else {
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(photosPerPage)")
        ]
        guard let url = urlComponents.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
