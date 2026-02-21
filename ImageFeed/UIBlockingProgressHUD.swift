//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Ilia Degtiarev on 21.02.26.
//

import ProgressHUD
import UIKit

enum UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }

    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }

    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
