//
//  OnboardingCell.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 12.10.2025.
//

import UIKit

enum OnboardingUITheme {
    static let accentCyan   = UIColor(displayP3Red: 0.00, green: 0.82, blue: 0.92, alpha: 1)
    static let accentPurple = UIColor(displayP3Red: 0.77, green: 0.33, blue: 1.00, alpha: 1)
    static let starWhite    = UIColor(white: 1, alpha: 0.92)
}

final class OnboardingPageCell: UICollectionViewCell {
    static let reuseID = "OnboardingPageCell"

    private let heroView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let bulletStack = UIStackView()
    private let heroHalo = CAGradientLayer()

    var aspectMultiplier: CGFloat = 3.0/3.0 {
        didSet {
            heroHeightConstraint?.isActive = false
            heroHeightConstraint = heroView.heightAnchor.constraint(equalTo: heroView.widthAnchor, multiplier: aspectMultiplier)
            heroHeightConstraint?.isActive = true
            setNeedsLayout()
        }
    }
    private var heroHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) { super.init(frame: frame); configure() }
    required init?(coder: NSCoder) { super.init(coder: coder); configure() }

    private func configure() {
        contentView.backgroundColor = .clear

        heroView.translatesAutoresizingMaskIntoConstraints = false
        heroView.contentMode = .scaleAspectFill
        heroView.clipsToBounds = true
        heroView.layer.cornerRadius = 18
        heroView.layer.borderWidth  = 0.5
        heroView.layer.borderColor  = UIColor.white.withAlphaComponent(0.15).cgColor

        heroHalo.colors = [OnboardingUITheme.accentPurple.withAlphaComponent(0.55).cgColor,
                           OnboardingUITheme.accentCyan.withAlphaComponent(0.55).cgColor]
        heroHalo.startPoint = CGPoint(x: 0, y: 0)
        heroHalo.endPoint   = CGPoint(x: 1, y: 1)
        heroHalo.cornerRadius = 18
        heroHalo.opacity = 0.5
        heroView.layer.insertSublayer(heroHalo, at: 0)
        heroHalo.isHidden = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 30, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 1, alpha: 0.86)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .left

        bulletStack.translatesAutoresizingMaskIntoConstraints = false
        bulletStack.axis = .vertical
        bulletStack.spacing = 10
        bulletStack.distribution = .fill

        contentView.addSubview(heroView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(bulletStack)

        heroHeightConstraint = heroView.heightAnchor.constraint(equalTo: heroView.widthAnchor, multiplier: aspectMultiplier)
        heroHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            heroView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            heroView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            heroView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: heroView.bottomAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            bulletStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            bulletStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bulletStack.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bulletStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -28)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        heroHalo.frame = heroView.bounds
    }

    func configure(with page: OnboardingPage) {
        heroView.image = UIImage(named: page.heroImageName)
        titleLabel.text = page.title
        subtitleLabel.text = page.subtitle

        bulletStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for b in page.bullets {
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .top
            row.spacing = 8

            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = OnboardingUITheme.accentCyan
            dot.layer.cornerRadius = 3
            dot.widthAnchor.constraint(equalToConstant: 6).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 6).isActive = true

            let label = UILabel()
            label.text = b.text
            label.numberOfLines = 0
            label.textColor = OnboardingUITheme.starWhite
            label.font = .systemFont(ofSize: 15, weight: .semibold)

            row.addArrangedSubview(dot)
            row.addArrangedSubview(label)
            bulletStack.addArrangedSubview(row)
        }
    }
}
