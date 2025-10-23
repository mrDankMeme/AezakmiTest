//
//  FileImageLoader.swift
//  AezakmiTest
//
//  Created by Niiaz Khasanov on 10/23/25.
//


import UIKit
import ImageIO
import MobileCoreServices

enum FileImageLoader {
    static func loadFirstImage(from url: URL) -> UIImage? {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        guard let cg = CGImageSourceCreateImageAtIndex(src, 0, [kCGImageSourceShouldCache: true as CFBoolean] as CFDictionary) else { return nil }
        return UIImage(cgImage: cg, scale: UIScreen.main.scale, orientation: .up)
    }
}
