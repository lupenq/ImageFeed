//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Ilia Degtiarev on 26.12.25.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    @IBOutlet var imageCellView: UIImageView!
    @IBOutlet var likeButtonView: UIButton!
    @IBOutlet var dateLabelView: UILabel!
}
