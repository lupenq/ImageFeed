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

    func reset() {
        task?.cancel()
        task = nil
        photos = []
        lastLoadedPage = 0
    }

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
                print("[ImagesListService fetchPhotosNextPage]: failure - page: \(nextPage), error: \(error.localizedDescription)")
            }
            self.task = nil
        }

        self.task = task
        task.resume()
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token,
              let url = URL(string: "\(Constants.defaultBaseURLString)/photos/\(photoId)/like")
        else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self
                        )
                    }
                    completion(.success(()))
                }
            case .failure(let error):
                print("[ImagesListService changeLike]: failure - photoId: \(photoId), isLike: \(isLike), error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
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
