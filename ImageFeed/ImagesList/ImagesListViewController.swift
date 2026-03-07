//
//  ViewController.swift
//  ImageFeed
//
//  Created by Ilia Degtiarev on 25.12.25.
//

import Kingfisher
import UIKit

class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateTableViewAnimated()
            }

        imagesListService.fetchPhotosNextPage()
    }

    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount ..< newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]

        cell.imageCellView.kf.indicatorType = .activity
        if let url = URL(string: photo.thumbImageURL) {
            cell.imageCellView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "stub_photo")
            ) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                case .failure:
                    break
                }
            }
        } else {
            cell.imageCellView.image = UIImage(named: "stub_photo")
        }

        if let date = photo.createdAt {
            cell.dateLabelView.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabelView.text = ""
        }

        cell.setIsLiked(photo.isLiked)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) // 1

        guard let imageListCell = cell as? ImagesListCell else { // 2
            return UITableViewCell()
        }

        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath) // 3
        return imageListCell // 4
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageRatio = photo.size.height / photo.size.width
        let cellWidth = tableView.bounds.width - tableView.contentInset.left - tableView.contentInset.right
        return cellWidth * imageRatio
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]

        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                case .failure:
                    // TODO: Показать ошибку с использованием UIAlertController
                    break
                }
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}
