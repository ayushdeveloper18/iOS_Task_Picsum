//
//  ImageCache.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//

import Foundation
import UIKit


final class ImageCache {
    static let shared = ImageCache()
    private let mem = NSCache<NSURL, UIImage>()
    private let fm = FileManager.default
    private let diskDir: URL

    private init() {
        if let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask).first {
            diskDir = caches.appendingPathComponent("PicsumImageCache")
            try? fm.createDirectory(at: diskDir, withIntermediateDirectories: true)
        } else {
            diskDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("PicsumImageCache")
        }
        mem.totalCostLimit = 150 * 1024 * 1024 // ~150MB
    }

    subscript(url: URL) -> UIImage? {
        get {
            if let img = mem.object(forKey: url as NSURL) { return img }
            let file = diskDir.appendingPathComponent(fileName(for: url))
            if let data = try? Data(contentsOf: file), let img = UIImage(data: data) {
                mem.setObject(img, forKey: url as NSURL)
                return img
            }
            return nil
        }
        set {
            if let img = newValue {
                mem.setObject(img, forKey: url as NSURL)
                DispatchQueue.global(qos: .background).async {
                    let file = self.diskDir.appendingPathComponent(self.fileName(for: url))
                    if let data = img.pngData() { try? data.write(to: file, options: .atomic) }
                }
            } else {
                mem.removeObject(forKey: url as NSURL)
            }
        }
    }

    private func fileName(for url: URL) -> String {
        let raw = (url.host ?? "") + url.path + (url.query ?? "")
        if let data = raw.data(using: .utf8) {
            return data.base64EncodedString()
        } else {
            return UUID().uuidString
        }
    }
}
