//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Ilia Degtiarev on 26.12.25.
//

import Kingfisher
import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    private let gradientLayer = CAGradientLayer()

    weak var delegate: ImagesListCellDelegate?

    @IBOutlet var imageCellView: UIImageView!
    @IBOutlet var likeButtonView: UIButton!
    @IBOutlet var dateLabelView: UILabel!
    @IBOutlet var gradientView: UIView!

    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }

    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "Favorite Active") : UIImage(named: "Favorite Inactive")
        likeButtonView.setImage(likeImage, for: .normal)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        gradientView.layer.cornerRadius = 8

        gradientView.layer.maskedCorners = [
            .layerMinXMaxYCorner, // bottom-left
            .layerMaxXMaxYCorner // bottom-right
        ]
        gradientView.layer.masksToBounds = true

        gradientLayer.frame = gradientView.bounds

        gradientLayer.colors = [
            UIColor(named: "YP Black")?.withAlphaComponent(0).cgColor ?? "",
            UIColor(named: "YP Black")?.withAlphaComponent(1.0).cgColor ?? ""
        ]

        gradientLayer.locations = [
            0.0,
            1.0
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        if gradientLayer.superlayer == nil {
            gradientView.layer.addSublayer(gradientLayer)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = gradientView.bounds
        CATransaction.commit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageCellView.kf.cancelDownloadTask()
    }
}
