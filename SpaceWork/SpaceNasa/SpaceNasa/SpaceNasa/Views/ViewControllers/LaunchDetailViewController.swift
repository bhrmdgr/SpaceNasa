//
//  LaunchDetailViewController.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 4.10.2025.
//

import UIKit

final class LaunchDetailViewController: UIViewController {

    var viewModel: LaunchDetailViewModelProtocol!

    // THEME
    private struct Theme {
        static let accent      = UIColor(displayP3Red: 0.0, green: 0.82, blue: 0.92, alpha: 1.0) // neon cyan
        static let cardStroke  = UIColor.white.withAlphaComponent(0.08)
        static let label       = UIColor(white: 0.96, alpha: 1.0)
        static let sublabel    = UIColor(white: 0.72, alpha: 1.0)
        static let value       = UIColor(white: 0.92, alpha: 1.0)
        static let warn        = UIColor.systemOrange
        static let danger      = UIColor.systemRed
        static let success     = UIColor.systemGreen
    }

    // UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let imageContainer = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    // Status
    private let statusContainer = UIView()
    private let statusValue = UILabel()
    private let statusDescValue = UILabel()

    // Basics
    private let netValue = UILabel()
    private let providerValue = UILabel()
    private let providerTypeValue = UILabel()
    private let padValue = UILabel()
    private let siteValue = UILabel()
    private let countryValue = UILabel()

    // Rocket
    private let rocketFullNameValue = UILabel()
    private let rocketFamilyValue = UILabel()
    private let rocketVariantValue = UILabel()

    // Mission
    private let missionNameValue = UILabel()
    private let missionTypeValue = UILabel()
    private let missionOrbitValue = UILabel()
    private let missionDescValue = UILabel()

    private var spinner: UIActivityIndicatorView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.tintColor = Theme.accent
        view.backgroundColor = .black

        // Global arka plan (extension’dan)
        setBackgroundImage(named: "background.jpg", dimAlpha: 0.20)

        configureLayout()
        applyTheme()
        bind()
        viewModel.viewDidLoad()
    }

    private func bind() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            state.isLoading ? self.showLoading() : self.hideLoading()
            if let msg = state.errorMessage, !msg.isEmpty { self.presentAlert(message: msg) }
            if let data = state.data { self.apply(data) }
        }
    }

    // MARK: - Layout
    private func configureLayout() {
        navigationItem.title = "Launch Detail"

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .always
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])


        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.layer.cornerRadius = 16
        imageContainer.layer.masksToBounds = true
        imageContainer.heightAnchor.constraint(equalToConstant: 240).isActive = true

        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor)
        ])


        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = Theme.label
        titleLabel.layer.shadowColor = Theme.accent.cgColor
        titleLabel.layer.shadowRadius = 6
        titleLabel.layer.shadowOpacity = 0.35
        titleLabel.layer.shadowOffset = .zero


        let statusTitle = labeledStack(title: "Status", valueLabel: statusValue)
        let statusDesc  = labeledStack(title: "Status Description", valueLabel: statusDescValue)
        let statusVStack = UIStackView(arrangedSubviews: [statusTitle, statusDesc])
        statusVStack.axis = .vertical
        statusVStack.spacing = 8
        let statusCard = makeCard(containing: statusVStack)
        statusContainer.addSubview(statusCard)
        statusCard.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusCard.topAnchor.constraint(equalTo: statusContainer.topAnchor),
            statusCard.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor),
            statusCard.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor),
            statusCard.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor)
        ])


        let netStack          = labeledStack(title: "NET", valueLabel: netValue)
        let providerStack     = labeledStack(title: "Provider", valueLabel: providerValue)
        let providerTypeStack = labeledStack(title: "Provider Type", valueLabel: providerTypeValue)
        let padStack          = labeledStack(title: "Pad", valueLabel: padValue)
        let siteStack         = labeledStack(title: "Site", valueLabel: siteValue)
        let countryStack      = labeledStack(title: "Country", valueLabel: countryValue)
        let baseGroup = makeCard(containing: vstack([netStack, providerStack, providerTypeStack, padStack, siteStack, countryStack], spacing: 10))


        let rocketFullStack    = labeledStack(title: "Rocket", valueLabel: rocketFullNameValue)
        let rocketFamilyStack  = labeledStack(title: "Rocket Family", valueLabel: rocketFamilyValue)
        let rocketVariantStack = labeledStack(title: "Rocket Variant", valueLabel: rocketVariantValue)
        let rocketGroup = makeCard(withHeader: "Rocket", body: vstack([rocketFullStack, rocketFamilyStack, rocketVariantStack], spacing: 10))


        let missionNameStack  = labeledStack(title: "Mission Name", valueLabel: missionNameValue)
        let missionTypeStack  = labeledStack(title: "Mission Type", valueLabel: missionTypeValue)
        let missionOrbitStack = labeledStack(title: "Mission Orbit", valueLabel: missionOrbitValue)
        let missionDescStack  = labeledStack(title: "Mission Description", valueLabel: missionDescValue)
        let missionGroup = makeCard(withHeader: "Mission", body: vstack([missionNameStack, missionTypeStack, missionOrbitStack, missionDescStack], spacing: 10))


        contentStack.addArrangedSubview(imageContainer)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(statusContainer)
        contentStack.addArrangedSubview(baseGroup)
        contentStack.addArrangedSubview(rocketGroup)
        contentStack.addArrangedSubview(missionGroup)
    }

    // MARK: - Theme
    private func applyTheme() {
        statusContainer.layer.cornerRadius = 16
        statusContainer.layer.shadowColor = Theme.accent.cgColor
        statusContainer.layer.shadowOpacity = 0.30
        statusContainer.layer.shadowRadius = 10
        statusContainer.layer.shadowOffset = .zero
        view.setNeedsLayout()
    }

    private func labeledStack(title: String, valueLabel: UILabel) -> UIStackView {
        let t = UILabel()
        t.text = title
        t.font = .preferredFont(forTextStyle: .subheadline)
        t.textColor = Theme.sublabel

        valueLabel.font = .preferredFont(forTextStyle: .body)
        valueLabel.numberOfLines = 0
        valueLabel.textColor = Theme.value

        let stack = UIStackView(arrangedSubviews: [t, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    private func sectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .preferredFont(forTextStyle: .headline)
        l.textColor = Theme.label
        return l
    }

    private func vstack(_ views: [UIView], spacing: CGFloat) -> UIStackView {
        let s = UIStackView(arrangedSubviews: views)
        s.axis = .vertical
        s.spacing = spacing
        return s
    }

    // Cam etkili şeffaf kart
    private func makeCard(containing content: UIView) -> UIView {
        let bg = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        bg.layer.cornerRadius = 16
        bg.layer.masksToBounds = true
        bg.layer.borderColor = Theme.cardStroke.cgColor
        bg.layer.borderWidth = 1
        bg.backgroundColor = .clear

        let inset = UIStackView(arrangedSubviews: [content])
        inset.axis = .vertical
        inset.isLayoutMarginsRelativeArrangement = true
        inset.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        bg.contentView.addSubview(inset)
        inset.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inset.topAnchor.constraint(equalTo: bg.contentView.topAnchor),
            inset.bottomAnchor.constraint(equalTo: bg.contentView.bottomAnchor),
            inset.leadingAnchor.constraint(equalTo: bg.contentView.leadingAnchor),
            inset.trailingAnchor.constraint(equalTo: bg.contentView.trailingAnchor)
        ])
        return bg
    }

    private func makeCard(withHeader title: String, body: UIView) -> UIView {
        let header = sectionHeader(title)
        header.layer.shadowColor = Theme.accent.cgColor
        header.layer.shadowOpacity = 0.3
        header.layer.shadowRadius = 6
        header.layer.shadowOffset = .zero
        let stack = vstack([header, body], spacing: 10)
        return makeCard(containing: stack)
    }

    // MARK: - Apply
    private func apply(_ data: LaunchDetailViewData) {
        navigationItem.title = "Launch Detail"
        titleLabel.text = data.title

        set(statusValue, text: data.statusText)
        set(statusDescValue, text: data.statusDescription)

        set(netValue, text: data.netText)
        set(providerValue, text: data.providerName)
        set(providerTypeValue, text: data.providerType)
        set(padValue, text: data.padName)
        set(siteValue, text: data.siteName)
        set(countryValue, text: data.countryCode)

        set(rocketFullNameValue, text: data.rocketFullName)
        set(rocketFamilyValue, text: data.rocketFamily)
        set(rocketVariantValue, text: data.rocketVariant)

        set(missionNameValue, text: data.missionName)
        set(missionTypeValue, text: data.missionType)
        set(missionOrbitValue, text: data.missionOrbit)
        set(missionDescValue, text: data.missionDescription)

        // HERO IMAGE / PLACEHOLDER (sadece 🚀)
        if let url = data.imageURL,
           !url.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ImageLoader.shared.setImage(
                on: imageView,
                from: url,
                placeholder: rocketOnlyPlaceholder(),
                targetPointSize: CGSize(width: view.bounds.width - 32, height: 240)
            )
        } else {
            imageView.image = rocketOnlyPlaceholder()
        }
    }

    // Sadece roket emojili placeholder
    private func rocketOnlyPlaceholder() -> UIImage {
        let width = max(view.bounds.width - 32, 320)
        let size = CGSize(width: width, height: 240)
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { ctx in
            // Koyu uzay gradyanı
            let colors = [
                UIColor(red: 0.06, green: 0.07, blue: 0.14, alpha: 1).cgColor,
                UIColor(red: 0.02, green: 0.02, blue: 0.06, alpha: 1).cgColor
            ] as CFArray
            let locs: [CGFloat] = [0, 1]
            let space = CGColorSpaceCreateDeviceRGB()
            if let grad = CGGradient(colorsSpace: space, colors: colors, locations: locs) {
                ctx.cgContext.drawLinearGradient(
                    grad,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: 0, y: size.height),
                    options: []
                )
            } else {
                UIColor.black.setFill()
                ctx.fill(CGRect(origin: .zero, size: size))
            }

            // Hafif yıldızlar
            ctx.cgContext.setFillColor(UIColor(white: 1, alpha: 0.15).cgColor)
            for _ in 0..<50 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let r = CGFloat.random(in: 0.5...1.1)
                ctx.fill(CGRect(x: x, y: y, width: r, height: r))
            }

            // Roket emojisi
            let rocket: NSString = "🚀"
            let font = UIFont.systemFont(ofSize: 56, weight: .semibold)
            let attrs: [NSAttributedString.Key: Any] = [.font: font]
            let s = rocket.size(withAttributes: attrs)
            let origin = CGPoint(x: (size.width - s.width)/2, y: (size.height - s.height)/2)
            rocket.draw(at: origin, withAttributes: attrs)
        }
    }

    private func set(_ label: UILabel, text: String?) {
        if let t = text, !t.isEmpty {
            label.text = t
            label.superview?.isHidden = false
        } else {
            label.text = nil
            label.superview?.isHidden = true
        }
    }

    // MARK: - Loading
    private func showLoading() {
        if spinner != nil { return }
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.color = Theme.accent
        view.addSubview(ai)
        NSLayoutConstraint.activate([
            ai.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ai.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        ai.startAnimating()
        spinner = ai
    }

    private func hideLoading() {
        spinner?.removeFromSuperview()
        spinner = nil
    }

    // MARK: - Alerts
    private func presentAlert(title: String = "Error", message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
