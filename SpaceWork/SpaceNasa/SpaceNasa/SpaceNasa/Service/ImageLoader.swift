//
//  ImageLoader.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 6.10.2025.
//

import UIKit
import ImageIO

final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()
    /// Her imageView için aktif task
    private let taskTable = NSMapTable<UIImageView, URLSessionDataTask>(keyOptions: .weakMemory, valueOptions: .strongMemory)
    /// Her imageView için beklenen URL (yarış koşulu önlemek için)
    private let urlTable  = NSMapTable<UIImageView, NSURL>(keyOptions: .weakMemory, valueOptions: .strongMemory)

    private init() {}

    /// Dışarıdan iptal etmek için
    func cancelImageRequest(for imageView: UIImageView) {
        if let task = taskTable.object(forKey: imageView) {
            task.cancel()
        }
        taskTable.removeObject(forKey: imageView)
        urlTable.removeObject(forKey: imageView)
    }

    func setImage(on imageView: UIImageView,
                  from url: URL,
                  placeholder: UIImage? = nil,
                  targetPointSize: CGSize? = nil)
    {
        // Önce önceki isteği iptal et
        cancelImageRequest(for: imageView)

        imageView.image = placeholder

        // Önbellek
        let nsURL = url as NSURL
        if let cached = cache.object(forKey: nsURL) {
            imageView.image = cached
            return
        }

        // Bu imageView'in beklediği URL budur
        urlTable.setObject(nsURL, forKey: imageView)

        let task = URLSession.shared.dataTask(with: url) { [weak self, weak imageView] data, _, _ in
            guard let self, let imageView else { return }

            // Hâlâ aynı URL mi? (Reuse'ta yanlış bind'i keser)
            guard let expected = self.urlTable.object(forKey: imageView) as URL?, expected == url else {
                return
            }

            guard let data else {
                // İş bitti; kayıtları temizle
                self.taskTable.removeObject(forKey: imageView)
                return
            }

            let image: UIImage?
            if let target = targetPointSize {
                image = self.downsample(data: data, to: target, scale: UIScreen.main.scale)
            } else {
                image = UIImage(data: data)
            }

            guard let img = image else {
                self.taskTable.removeObject(forKey: imageView)
                return
            }

            self.cache.setObject(img, forKey: nsURL)
            DispatchQueue.main.async {
                // Yine de son kez kontrol et
                if let expected2 = self.urlTable.object(forKey: imageView) as URL?, expected2 == url {
                    imageView.image = img
                }
                // Temizlik
                self.taskTable.removeObject(forKey: imageView)
                self.urlTable.removeObject(forKey: imageView)
            }
        }

        // Kaydet & başlat
        taskTable.setObject(task, forKey: imageView)
        task.resume()
    }

    // Downsample aynı
    private func downsample(data: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        let cfData = data as CFData
        let sourceOptions: [CFString: Any] = [kCGImageSourceShouldCache: false]
        guard let src = CGImageSourceCreateWithData(cfData, sourceOptions as CFDictionary) else { return nil }

        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(src, 0, downsampleOptions as CFDictionary) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
