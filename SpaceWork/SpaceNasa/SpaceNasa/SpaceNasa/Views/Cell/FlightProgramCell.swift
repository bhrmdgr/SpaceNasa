//
//  FlightProgramCell.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 6.10.2025.
//

import UIKit

final class FlightProgramCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    private var aspectConstraint: NSLayoutConstraint?
    private let labelArea = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .clear
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit

        labelArea.translatesAutoresizingMaskIntoConstraints = false
        labelArea.backgroundColor = .clear
        contentView.addSubview(labelArea)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        if titleLabel.superview !== labelArea {
            titleLabel.removeFromSuperview()
            labelArea.addSubview(titleLabel)
        }

        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        titleLabel.backgroundColor = .clear

        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            labelArea.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            labelArea.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            labelArea.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            labelArea.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        aspectConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.70)
        aspectConstraint?.isActive = true

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: labelArea.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: labelArea.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: labelArea.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: labelArea.trailingAnchor, constant: -8)
        ])

        // Seçim geri bildirimi (şeffaf ton)
        let sbg = UIView()
        sbg.backgroundColor = UIColor.secondarySystemFill.withAlphaComponent(0.25)
        selectedBackgroundView = sbg

        isAccessibilityElement = false
        titleLabel.isAccessibilityElement = true
        imageView.isAccessibilityElement = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ImageLoader.shared.cancelImageRequest(for: imageView)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        imageView.image = nil
        imageView.backgroundColor = .clear
        imageView.tintColor = .systemGray3

        titleLabel.text = nil
        titleLabel.accessibilityLabel = nil
        titleLabel.accessibilityValue = nil
    }

    func configure(with item: ProgramItemViewData) {
        titleLabel.text = item.title
        titleLabel.accessibilityLabel = "Program başlığı"
        titleLabel.accessibilityValue = item.title

        layoutIfNeeded() // placeholder boyutunu netleştir
        let placeholder = makeEmojiPlaceholder(symbol: "🚀")

        if let url = item.imageURL {
            ImageLoader.shared.setImage(on: imageView, from: url, placeholder: placeholder)
        } else {
            imageView.image = placeholder
        }
    }

    // MARK: Emoji Placeholder
    private func makeEmojiPlaceholder(symbol: String) -> UIImage {
        let side = max(contentView.bounds.width, 80)
        let size = CGSize(width: side, height: side)

        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center

            let font = UIFont.systemFont(ofSize: side * 0.5, weight: .semibold)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.systemGray3,
                .paragraphStyle: paragraph
            ]

            let str = NSAttributedString(string: symbol, attributes: attrs)
            let textSize = str.size()
            let rect = CGRect(
                x: (size.width  - textSize.width)  / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            str.draw(in: rect)
        }
    }
}
