//
//  DashboardViewController.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 4.10.2025.
//

import UIKit

final class DashboardViewController: UIViewController, LoadingShowable {

    // MARK: - Theme
    private struct Theme {
        static let accent      = UIColor(displayP3Red: 0.00, green: 0.82, blue: 0.92, alpha: 1.0)
        static let accentSoft  = UIColor(displayP3Red: 0.00, green: 0.82, blue: 0.92, alpha: 0.18)
        static let cardStroke  = UIColor.white.withAlphaComponent(0.08)
        static let label       = UIColor(white: 0.96, alpha: 1.0)
        static let sublabel    = UIColor(white: 0.72, alpha: 1.0)
        static let bgDeep1     = UIColor(red: 0.02, green: 0.03, blue: 0.08, alpha: 1)
        static let bgDeep2     = UIColor(red: 0.01, green: 0.01, blue: 0.04, alpha: 1)
        static let bgDeep3     = UIColor.black
    }

    // Background layers
    private var gradientLayer: CAGradientLayer?
    private var starfieldLayer: CAEmitterLayer?
    private var imageOverlayLayer: CAGradientLayer?

    var programId: Int!
    private let viewModel: DashboardViewModelProtocol = DashboardViewModel()

    // UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    private let metricsStack = UIStackView()
    private let leftSlot = UIView()
    private let rightSlot = UIView()
    private let flightCountLabel = UILabel()
    private let successRateLabel = UILabel()

    // Inline metrics loading overlay
    private let metricsLoadingOverlay = UIStackView()
    private let metricsSpinner = UIActivityIndicatorView(style: .medium)
    private let metricsLoadingLabel: UILabel = {
        let l = UILabel()
        l.text = "Metrics are calculating…"
        l.font = .preferredFont(forTextStyle: .footnote)
        l.textAlignment = .center
        l.textColor = Theme.sublabel
        return l
    }()

    // Bottom bar , button
    private let bottomBar = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    private let launchesButton = UIButton(type: .system)

    private var imageAspectConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Program"
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = .black
        view.tintColor = Theme.accent

        setBackgroundImage(named: "background.jpg", dimAlpha: 0.20)

        setupCosmicBackground()
        setupNavAppearance()
        buildUI()
        layoutUI()
        styleUI()
        bindVM()

        viewModel.load(programId: programId)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ImageLoader.shared.cancelImageRequest(for: imageView)
    }

    // MARK: - Build
    private func buildUI() {
        view.addSubview(scrollView)
        view.addSubview(bottomBar)
        scrollView.addSubview(contentView)
        contentView.addSubview(stack)

        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill

        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(titleLabel)

        metricsStack.axis = .horizontal
        metricsStack.spacing = 12
        metricsStack.alignment = .center
        metricsStack.distribution = .fillEqually
        stack.addArrangedSubview(metricsStack)

        metricsStack.addArrangedSubview(leftSlot)
        metricsStack.addArrangedSubview(rightSlot)

        leftSlot.addSubview(flightCountLabel)
        rightSlot.addSubview(successRateLabel)

        [flightCountLabel, successRateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.centerXAnchor.constraint(equalTo: $0.superview!.centerXAnchor),
                $0.centerYAnchor.constraint(equalTo: $0.superview!.centerYAnchor),
                $0.leadingAnchor.constraint(greaterThanOrEqualTo: $0.superview!.leadingAnchor, constant: 8),
                $0.trailingAnchor.constraint(lessThanOrEqualTo: $0.superview!.trailingAnchor, constant: -8)
            ])
        }

        metricsStack.addSubview(metricsLoadingOverlay)
        metricsLoadingOverlay.axis = .horizontal
        metricsLoadingOverlay.alignment = .center
        metricsLoadingOverlay.distribution = .fill
        metricsLoadingOverlay.spacing = 8
        metricsLoadingOverlay.isLayoutMarginsRelativeArrangement = true
        metricsLoadingOverlay.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        metricsLoadingOverlay.addArrangedSubview(metricsSpinner)
        metricsLoadingOverlay.addArrangedSubview(metricsLoadingLabel)
        metricsLoadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            metricsLoadingOverlay.leadingAnchor.constraint(equalTo: metricsStack.leadingAnchor),
            metricsLoadingOverlay.trailingAnchor.constraint(equalTo: metricsStack.trailingAnchor),
            metricsLoadingOverlay.topAnchor.constraint(equalTo: metricsStack.topAnchor),
            metricsLoadingOverlay.bottomAnchor.constraint(equalTo: metricsStack.bottomAnchor)
        ])

        stack.addArrangedSubview(descriptionLabel)

        bottomBar.contentView.addSubview(launchesButton)
        launchesButton.addTarget(self, action: #selector(showLaunchesTapped), for: .touchUpInside)
    }

    // MARK: - Layout
    private func layoutUI() {
        [scrollView, contentView, stack, imageView, bottomBar, launchesButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let barTop = bottomBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64)
        barTop.priority = .defaultHigh
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            barTop,
            bottomBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        imageAspectConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 9.0/16.0)
        imageAspectConstraint?.isActive = true

        NSLayoutConstraint.activate([
            launchesButton.leadingAnchor.constraint(equalTo: bottomBar.contentView.layoutMarginsGuide.leadingAnchor, constant: 8),
            launchesButton.trailingAnchor.constraint(equalTo: bottomBar.contentView.layoutMarginsGuide.trailingAnchor, constant: -8),
            launchesButton.topAnchor.constraint(equalTo: bottomBar.contentView.topAnchor, constant: 10),
            launchesButton.bottomAnchor.constraint(equalTo: bottomBar.contentView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            launchesButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
    }

    // MARK: - Style
    private func styleUI() {
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true

        // subtle gradient on image bottom
        let overlay = CAGradientLayer()
        overlay.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        overlay.locations = [0.55, 1.0]
        overlay.frame = imageView.bounds
        imageView.layer.addSublayer(overlay)
        imageOverlayLayer = overlay

        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = Theme.label
        titleLabel.layer.shadowColor = Theme.accent.cgColor
        titleLabel.layer.shadowRadius = 6
        titleLabel.layer.shadowOpacity = 0.30
        titleLabel.layer.shadowOffset = .zero

        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = Theme.sublabel

        // metrics — glassy panel (YAN YANA ve TEK SATIR kalacak şekilde güncellendi)
        metricsStack.isLayoutMarginsRelativeArrangement = true
        metricsStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        metricsStack.layer.cornerRadius = 16
        metricsStack.layer.masksToBounds = true
        metricsStack.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        metricsStack.layer.borderColor = Theme.cardStroke.cgColor
        metricsStack.layer.borderWidth = 1
        metricsStack.alignment = .fill
        metricsStack.distribution = .fillEqually
        metricsStack.spacing = 8

        [flightCountLabel, successRateLabel].forEach {
            $0.font = .preferredFont(forTextStyle: .subheadline)
            $0.textAlignment = .center
            $0.textColor = Theme.label

            $0.numberOfLines = 1
            $0.lineBreakMode = .byTruncatingTail
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.85

            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            $0.setContentHuggingPriority(.defaultLow, for: .vertical)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

            $0.adjustsFontForContentSizeCategory = true
            $0.isHidden = true
        }


        metricsLoadingOverlay.backgroundColor = .clear
        metricsSpinner.hidesWhenStopped = true
        showMetricsLoading(true)

        bottomBar.effect = UIBlurEffect(style: .systemChromeMaterialDark)
        bottomBar.clipsToBounds = true
        bottomBar.layer.shadowColor = UIColor.black.cgColor
        bottomBar.layer.shadowOpacity = 0.20
        bottomBar.layer.shadowRadius = 10
        bottomBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        bottomBar.contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        launchesButton.setTitle("Show Launches", for: .normal)
        launchesButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        launchesButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        launchesButton.backgroundColor = Theme.accent
        launchesButton.tintColor = .black
        launchesButton.layer.cornerRadius = 14
        launchesButton.layer.shadowColor = Theme.accent.cgColor
        launchesButton.layer.shadowOpacity = 0.55
        launchesButton.layer.shadowRadius = 12
        launchesButton.layer.shadowOffset = .zero

        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        scrollView.accessibilityIdentifier = "dashboard_scrollView"
        bottomBar.accessibilityIdentifier = "dashboard_bottomBar"
        launchesButton.accessibilityIdentifier = "dashboard_launchesButton"
    }

    // MARK: - Bind
    private func bindVM() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .idle:
                break
            case .loading:
                self.showLoading()
                self.showMetricsLoading(true)
            case .content(let viewData):
                self.hideLoading()
                self.apply(viewData: viewData)
                self.updateMetricsLoading(for: viewData)
                self.view.layoutIfNeeded()
                self.scrollView.flashScrollIndicators()
            case .error(let message):
                self.hideLoading()
                self.showMetricsLoading(false)
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }

    // MARK: - Apply
    private func apply(viewData: DashboardViewData) {
        titleLabel.text = viewData.title
        descriptionLabel.text = viewData.description

        if let url = viewData.imageURL {
            ImageLoader.shared.setImage(
                on: imageView,
                from: url,
                placeholder: UIImage(systemName: "photo")
            )
            imageView.tintColor = .clear
        } else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .tertiaryLabel
        }

        if let t = viewData.flightCountText {
            flightCountLabel.text = t
            flightCountLabel.alpha = viewData.isApprox ? 0.8 : 1.0
            flightCountLabel.isHidden = false
        } else {
            flightCountLabel.isHidden = true
        }

        if let t = viewData.successRateText {
            successRateLabel.text = t
            successRateLabel.alpha = viewData.isApprox ? 0.8 : 1.0
            successRateLabel.isHidden = false
        } else {
            successRateLabel.isHidden = true
        }

        updateMetricsLoading(for: viewData)
    }

    // MARK: - Actions
    
    private func parsedTotalFlights() -> Int? {
        guard let s = flightCountLabel.text else { return nil }
        let digits = s.compactMap { $0.isNumber ? $0 : nil }
        return Int(String(digits))
    }

    
    @objc private func showLaunchesTapped() {
        if (parsedTotalFlights() ?? 0) == 0 {
            let ac = UIAlertController(title: "No Launches",
                                       message: "There are no launches to show yet.",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        let vc = LaunchListViewController()
        vc.programId = self.programId
        navigationController?.pushViewController(vc, animated: true)
    }



    // MARK: - Cosmic background (style only)
    private func setupCosmicBackground() {
        let g = CAGradientLayer()
        g.colors = [Theme.bgDeep1.cgColor, Theme.bgDeep2.cgColor, Theme.bgDeep3.cgColor]
        g.locations = [0, 0.55, 1]
        g.frame = view.bounds
        g.name = "cosmosGradientDashboard"
        view.layer.insertSublayer(g, at: 0)
        gradientLayer = g

        let star = CAEmitterCell()
        star.contents = UIImage(systemName: "circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 2, weight: .regular))
            .withTintColor(.white, renderingMode: .alwaysOriginal)
            .cgImage
        star.birthRate = 2
        star.lifetime = 40
        star.velocity = 10
        star.velocityRange = 14
        star.scale = 0.2
        star.alphaSpeed = -0.005
        star.emissionLongitude = .pi
        star.color = UIColor(white: 1, alpha: 0.30).cgColor

        let emitter = CAEmitterLayer()
        emitter.emitterShape = .line
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -4)
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitter.emitterCells = [star]
        view.layer.insertSublayer(emitter, above: g)
        starfieldLayer = emitter
    }

    private func setupNavAppearance() {
        let ap = UINavigationBarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        ap.titleTextAttributes = [.foregroundColor: Theme.label, .font: UIFont.systemFont(ofSize: 18, weight: .semibold)]
        ap.largeTitleTextAttributes = [.foregroundColor: Theme.label]
        ap.shadowColor = UIColor.white.withAlphaComponent(0.06)
        navigationItem.standardAppearance = ap
        navigationItem.scrollEdgeAppearance = ap
        navigationController?.navigationBar.tintColor = Theme.accent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        starfieldLayer?.emitterPosition = CGPoint(x: view.bounds.midX, y: -4)
        starfieldLayer?.emitterSize = CGSize(width: view.bounds.width, height: 1)
        imageOverlayLayer?.frame = imageView.bounds
    }

    // MARK: - Inline loading helpers
    private func showMetricsLoading(_ show: Bool) {
        metricsLoadingOverlay.isHidden = !show
        show ? metricsSpinner.startAnimating() : metricsSpinner.stopAnimating()
    }

    private func updateMetricsLoading(for viewData: DashboardViewData) {
        let hasCount = viewData.flightCountText != nil
        let hasRate  = viewData.successRateText != nil
        showMetricsLoading(!(hasCount || hasRate))
    }
}
