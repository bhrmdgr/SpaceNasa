//
//  UIBackground.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 11.10.2025.
//

// Extensions/UIViewController+Background.swift
import UIKit
import ObjectiveC


private enum BGKeys {
    static var container: UInt8 = 0
    static var imageView: UInt8 = 0
    static var dimView: UInt8 = 0
}

public extension UIViewController {

    func setBackgroundImage(named name: String,
                            dimAlpha: CGFloat = 0.20,
                            contentMode: UIView.ContentMode = .scaleAspectFill) {
        // Mevcutsa güncelle
        if let container = objc_getAssociatedObject(self, &BGKeys.container) as? UIView,
           let imageView = objc_getAssociatedObject(self, &BGKeys.imageView) as? UIImageView,
           let dimView = objc_getAssociatedObject(self, &BGKeys.dimView) as? UIView {
            imageView.image = UIImage(named: name)
            imageView.contentMode = contentMode
            dimView.backgroundColor = UIColor(white: 0, alpha: dimAlpha)
            view.sendSubviewToBack(container)
            return
        }

        // Yeni kurulum
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: name)
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true

        let dimView = UIView()
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor(white: 0, alpha: dimAlpha)

        container.addSubview(imageView)
        container.addSubview(dimView)
        view.addSubview(container)
        view.sendSubviewToBack(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            dimView.topAnchor.constraint(equalTo: container.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // Associated object’leri güvenli key’lerle bağla
        objc_setAssociatedObject(self, &BGKeys.container, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &BGKeys.imageView, imageView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &BGKeys.dimView, dimView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func updateBackgroundDim(alpha: CGFloat) {
        if let dim = objc_getAssociatedObject(self, &BGKeys.dimView) as? UIView {
            dim.backgroundColor = UIColor(white: 0, alpha: alpha)
        }
    }

    func removeBackgroundImage() {
        (objc_getAssociatedObject(self, &BGKeys.container) as? UIView)?.removeFromSuperview()
        objc_setAssociatedObject(self, &BGKeys.container, nil, .OBJC_ASSOCIATION_ASSIGN)
        objc_setAssociatedObject(self, &BGKeys.imageView, nil, .OBJC_ASSOCIATION_ASSIGN)
        objc_setAssociatedObject(self, &BGKeys.dimView, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
}
