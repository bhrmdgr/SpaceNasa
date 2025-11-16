//
//  LaunchCell.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 10.10.2025.
//

import UIKit

final class PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
    override func drawText(in rect: CGRect) { super.drawText(in: rect.inset(by: insets)) }
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + insets.left + insets.right,
                      height: s.height + insets.top + insets.bottom)
    }
}

final class LaunchCell: UICollectionViewCell {

    static let reuseID = "LaunchCell"

    private enum Layout {
        static let cardCorner: CGFloat = 12
        static let imageSide: CGFloat = 72
        static let spacing: CGFloat = 10
    }

    private let cardView = UIView()
    private let thumbnailView = UIImageView()

    private let titleLabel = UILabel()
    private let statusChipLabel = PaddingLabel()
    private let subtitleLabel = UILabel()
    private let dateLabel = UILabel()

    private let textColumn = UIStackView()

    private let placeholderImage = UIImage(systemName: "photo")

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        dateLabel.text = nil
        statusChipLabel.text = nil
        statusChipLabel.backgroundColor = .clear
        statusChipLabel.textColor = .label
        statusChipLabel.isHidden = false
    }

    // MARK: - Configure
    func configure(with item: LaunchListItem) {
        titleLabel.text = item.name
        subtitleLabel.text = "\(item.rocketName ?? "Rocket Unknown") • \(item.locationName ?? "Location Unknown")"
        dateLabel.text = item.netText
        applyStatusStyle(abbrev: item.statusAbbrev)

        if let url = item.imageURL {
            ImageLoader.shared.setImage(on: thumbnailView, from: url, placeholder: placeholderImage)
        } else {
            thumbnailView.image = placeholderImage
            thumbnailView.tintColor = .tertiaryLabel
        }

        isAccessibilityElement = true
        accessibilityLabel = "\(item.name), \(item.netText), \(subtitleLabel.text ?? "")"
    }

    // MARK: - UI Build
    private func setupUI() {
        contentView.backgroundColor = .clear

        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = Layout.cardCorner
        cardView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false

        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.clipsToBounds = true
        thumbnailView.layer.cornerRadius = 8

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        statusChipLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        statusChipLabel.adjustsFontForContentSizeCategory = true
        statusChipLabel.layer.cornerRadius = 6
        statusChipLabel.clipsToBounds = true
        statusChipLabel.textAlignment = .center
        statusChipLabel.numberOfLines = 0
        statusChipLabel.lineBreakMode = .byWordWrapping
        statusChipLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        statusChipLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        statusChipLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        statusChipLabel.setContentHuggingPriority(.required, for: .vertical)

        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.lineBreakMode = .byTruncatingTail

        dateLabel.font = .preferredFont(forTextStyle: .footnote)
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.textColor = .tertiaryLabel
        dateLabel.numberOfLines = 1
        dateLabel.lineBreakMode = .byTruncatingTail

        textColumn.axis = .vertical
        textColumn.alignment = .fill
        textColumn.distribution = .fill
        textColumn.spacing = 6
        textColumn.addArrangedSubview(titleLabel)
        textColumn.addArrangedSubview(statusChipLabel)
        textColumn.addArrangedSubview(subtitleLabel)
        textColumn.addArrangedSubview(dateLabel)

        contentView.addSubview(cardView)
        [thumbnailView, textColumn].forEach { cardView.addSubview($0) }
    }

    private func setupConstraints() {
        [cardView, thumbnailView, textColumn].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            thumbnailView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.spacing),
            thumbnailView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Layout.spacing),
            thumbnailView.widthAnchor.constraint(equalToConstant: Layout.imageSide),
            thumbnailView.heightAnchor.constraint(equalToConstant: Layout.imageSide),
            thumbnailView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -Layout.spacing),

            textColumn.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Layout.spacing),
            textColumn.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: Layout.spacing),
            textColumn.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.spacing),
            textColumn.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Layout.spacing)
        ])
    }

    // MARK: - Self-sizing ölçümü kesinleştir
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetWidth = layoutAttributes.size.width > 0 ? layoutAttributes.size.width : bounds.width
        let targetSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
        attrs.size = CGSize(width: targetWidth, height: ceil(size.height))
        return attrs
    }

    // MARK: Durum metni ve stili
    private func expandedStatusText(for abbrev: String) -> String {
        switch abbrev {
        case "TBD":     return "To Be Determined"
        case "TBC":     return "To Be Confirmed"
        case "GO":      return "Go"
        case "NO-GO":   return "No-Go"
        case "HOLD":    return "Hold"
        case "SUCCESS": return "Success"
        case "FAILURE": return "Failure"
        default:        return abbrev.capitalized
        }
    }

    private func applyStatusStyle(abbrev: String?) {
        guard let raw = abbrev, !raw.isEmpty else {
            statusChipLabel.isHidden = true
            return
        }
        statusChipLabel.isHidden = false

        let upper = raw.uppercased()
        statusChipLabel.text = " \(expandedStatusText(for: upper)) "

        switch upper {
        case "SUCCESS", "GO":
            statusChipLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            statusChipLabel.textColor = .systemGreen
        case "FAILURE", "NO-GO":
            statusChipLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            statusChipLabel.textColor = .systemRed
        case "TBD", "TBC", "HOLD":
            statusChipLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            statusChipLabel.textColor = .systemOrange
        default:
            statusChipLabel.backgroundColor = UIColor.secondarySystemFill
            statusChipLabel.textColor = .secondaryLabel
        }
    }
}
