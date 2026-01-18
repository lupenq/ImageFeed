//
//  ViewController.swift
//  ImageFeed
//
//  Created by Ilia Degtiarev on 25.12.25.
//

import UIKit

class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    private let photosName: [String] = Array(0 ..< 20).map { "\($0)" }

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photoName = photosName[indexPath.row]

        if let image = UIImage(named: photoName) {
            cell.imageCellView.image = image
        } else {
            cell.imageCellView.image = UIImage()
        }

        cell.dateLabelView.text = dateFormatter.string(from: Date())

        if indexPath.row % 2 == 0 {
            cell.likeButtonView.setImage(UIImage(named: "Favorite Active"), for: .normal)
        } else {
            cell.likeButtonView.setImage(UIImage(named: "Favorite Inactive"), for: .normal)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier { // 1
            guard
                let viewController = segue.destination as? SingleImageViewController, // 2
                let indexPath = sender as? IndexPath // 3
            else {
                assertionFailure("Invalid segue destination") // 4
                return
            }

            let image = UIImage(named: photosName[indexPath.row]) // 5
            viewController.image = image // 6
        } else {
            super.prepare(for: segue, sender: sender) // 7
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) // 1

        guard let imageListCell = cell as? ImagesListCell else { // 2
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath) // 3
        return imageListCell // 4
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let image = UIImage(named: photosName[indexPath.row]) {
            let imageRatio = image.size.height / image.size.width
            let cellWidth = tableView.bounds.width - tableView.contentInset.left - tableView.contentInset.right
            return cellWidth * imageRatio
        } else {
            return 200 // Default height if image is not found
        }
    }
}
