//
//  OnboardingViewController.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 12.10.2025.
//

import UIKit

final class OnboardingViewController: UIViewController {

    // VM
    private let viewModel: OnboardingViewModelProtocol = OnboardingViewModel()

    // UI
    private var collectionView: UICollectionView!
    private let pageControl = UIPageControl()
    private let skipButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    // Arka plan
    private let bgImageView = UIImageView()
    private let vignette = CAGradientLayer()
    private let starEmitter = CAEmitterLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupBackground()
        setupCollection()
        setupControls()
        bind()
        viewModel.load()
    }

    // MARK: Bind
    private func bind() {
        viewModel.onChange = { [weak self] state in
            guard let self else { return }
            self.pageControl.numberOfPages = state.pages.count
            self.pageControl.currentPage = state.currentPage
            self.nextButton.setTitle(state.currentPage == (state.pages.count - 1) ? "Start" : "Next", for: .normal)
            if state.isFinished { self.dismiss(animated: true) }
        }
    }

    // MARK: Background (background.jpg + soft vignette + subtle stars)
    private func setupBackground() {
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.image = UIImage(named: "background")
        view.addSubview(bgImageView)
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        vignette.colors = [UIColor.black.withAlphaComponent(0.35).cgColor,
                           UIColor.black.withAlphaComponent(0.85).cgColor]
        vignette.startPoint = CGPoint(x: 0.2, y: 0)
        vignette.endPoint = CGPoint(x: 0.8, y: 1)
        view.layer.addSublayer(vignette)

        starEmitter.emitterShape = .line
        starEmitter.renderMode = .additive
        let cell = CAEmitterCell()
        cell.contents = UIImage(systemName: "sparkle")?.withTintColor(.white, renderingMode: .alwaysOriginal).cgImage
        cell.birthRate = 6
        cell.lifetime = 16
        cell.velocity = 50
        cell.velocityRange = 30
        cell.yAcceleration = 8
        cell.scale = 0.015
        cell.scaleRange = 0.02
        cell.alphaSpeed = -0.04
        starEmitter.emitterCells = [cell]
        view.layer.addSublayer(starEmitter)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        vignette.frame = view.bounds
        starEmitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
        starEmitter.emitterSize = CGSize(width: view.bounds.width, height: 2)
    }

    // MARK: CollectionView (Pager)
    private func setupCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(OnboardingPageCell.self, forCellWithReuseIdentifier: OnboardingPageCell.reuseID)

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: Controls
    private func setupControls() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = OnboardingUITheme.accentCyan
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.25)

        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(UIColor.white.withAlphaComponent(0.9), for: .normal)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        nextButton.setTitleColor(.black, for: .normal)
        nextButton.backgroundColor = OnboardingUITheme.accentCyan
        nextButton.layer.cornerRadius = 14
        nextButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 22, bottom: 14, right: 22)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        let bar = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.layer.cornerRadius = 24
        bar.clipsToBounds = true
        view.addSubview(bar)
        bar.contentView.addSubview(pageControl)
        bar.contentView.addSubview(skipButton)
        bar.contentView.addSubview(nextButton)

        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            bar.heightAnchor.constraint(equalToConstant: 64),

            pageControl.centerXAnchor.constraint(equalTo: bar.centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: bar.centerYAnchor),

            skipButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            skipButton.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 16),

            nextButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -12)
        ])

        let neon = CAGradientLayer()
        neon.colors = [OnboardingUITheme.accentPurple.cgColor, OnboardingUITheme.accentCyan.cgColor]
        neon.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 32, height: 64)
        neon.cornerRadius = 24
        neon.opacity = 0.55
        neon.startPoint = CGPoint(x: 0, y: 0)
        neon.endPoint = CGPoint(x: 1, y: 1)
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: neon.bounds.insetBy(dx: 1, dy: 1), cornerRadius: 24).cgPath
        shape.lineWidth = 2
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.white.withAlphaComponent(0.12).cgColor
        neon.mask = shape
        bar.layer.insertSublayer(neon, at: 0)
    }

    // MARK: Actions
    @objc private func skipTapped() { viewModel.skip() }

    @objc private func nextTapped() {
        // Geçerli sayfa
        let current = viewModel.state.currentPage
        let lastIndex = max(0, viewModel.state.pages.count - 1)

        // Son sayfadaysa onboarding'i bitir
        if current >= lastIndex {
            viewModel.skip()
            return
        }

        // Son değilse bir sonrakine ilerle
        let nextIndex = current + 1
        // VM'yi anında güncelle (buton metni ve pageControl için), scroll bitince tekrar set edilirse de zararsız
        viewModel.setPage(nextIndex)

        let indexPath = IndexPath(item: nextIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        if nextIndex == lastIndex { nextButton.pulse() }
    }
}

// MARK: - CollectionView
extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.state.pages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingPageCell.reuseID, for: indexPath) as! OnboardingPageCell
        cell.configure(with: viewModel.state.pages[indexPath.item])
        cell.aspectMultiplier = 3.0 / 3.5 // kare oran
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        viewModel.setPage(page)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        viewModel.setPage(page)
    }
}

// MARK: - Küçük yardımcı
private extension UIView {
    func pulse() {
        let a = CABasicAnimation(keyPath: "transform.scale")
        a.fromValue = 1.0; a.toValue = 1.06
        a.duration = 0.18; a.autoreverses = true
        layer.add(a, forKey: "pulse")
    }
}
