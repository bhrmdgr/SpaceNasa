//
//  LaunchListViewController.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 4.10.2025.
//

import UIKit
import SpaceNasaAPI

final class LaunchListViewController: UIViewController {

    // MARK: - Theme (aynı palet: Detay ekranıyla uyumlu)
    private struct Theme {
        static let accent      = UIColor(displayP3Red: 0.0, green: 0.82, blue: 0.92, alpha: 1.0) // neon cyan
        static let accentSoft  = UIColor(displayP3Red: 0.0, green: 0.82, blue: 0.92, alpha: 0.18)
        static let cardFill    = UIColor.white.withAlphaComponent(0.06)
        static let cardStroke  = UIColor.white.withAlphaComponent(0.08)
        static let label       = UIColor(white: 0.96, alpha: 1.0)
        static let sublabel    = UIColor(white: 0.72, alpha: 1.0)
        static let bgDeep1     = UIColor(red: 0.02, green: 0.03, blue: 0.08, alpha: 1)
        static let bgDeep2     = UIColor(red: 0.01, green: 0.01, blue: 0.04, alpha: 1)
        static let bgDeep3     = UIColor.black
    }

    var programId: Int!
    private let viewModel: LaunchListViewModelProtocol = LaunchListViewModel()

    private var isPresentingAlert = false
    private var didShowEmptyOnce = false

    private let segmented: UISegmentedControl = {
        let s = UISegmentedControl(items: ["Upcoming", "Realized"])
        s.selectedSegmentIndex = 0
        return s
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(LaunchCell.self, forCellWithReuseIdentifier: LaunchCell.reuseID)
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceVertical = true
        cv.contentInsetAdjustmentBehavior = .automatic
        return cv
    }()

    private let refreshControl = UIRefreshControl()

    // Kozmik arka plan
    private let bgView = UIView()
    private var gradient: CAGradientLayer?
    private var starfield: CAEmitterLayer?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        title = "Launches"
        view.tintColor = Theme.accent
        
        setBackgroundImage(named: "background.jpg", dimAlpha: 0.20)
        setupNavAppearance()
        setupLayout()
        setupSegmented()
        setupRefresh()
        bindVM()

        viewModel.configure(programId: programId)
        viewModel.setFilter(.upcoming)
        viewModel.reload()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.performBatchUpdates(nil) { _ in
            self.collectionView.layoutIfNeeded()
        }
    }

    // MARK: - Background
    

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

    // MARK: - Setup
    private func setupLayout() {
        [segmented, collectionView].forEach { v in
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }

        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmented.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSegmented() {
        segmented.addTarget(self, action: #selector(segChanged), for: .valueChanged)
        segmented.selectedSegmentTintColor = Theme.accentSoft
        segmented.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        segmented.layer.cornerRadius = 10
        segmented.layer.masksToBounds = true
        segmented.layer.borderColor = Theme.cardStroke.cgColor
        segmented.layer.borderWidth = 1

        let normal: [NSAttributedString.Key: Any] = [
            .foregroundColor: Theme.sublabel,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ]
        let selected: [NSAttributedString.Key: Any] = [
            .foregroundColor: Theme.label,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ]
        segmented.setTitleTextAttributes(normal, for: .normal)
        segmented.setTitleTextAttributes(selected, for: .selected)
    }

    private func setupRefresh() {
        refreshControl.tintColor = Theme.accent
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    // MARK: - Bind VM
    private func bindVM() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            if !state.isLoading {
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.layoutIfNeeded()
                self.refreshControl.endRefreshing()
            }

            if let msg = state.errorMessage, !msg.isEmpty {
                self.presentOneShotAlert(title: "Error", message: msg)
            }

            if state.shouldShowEmptyAlert, !self.didShowEmptyOnce {
                self.didShowEmptyOnce = true
                self.presentOneShotAlert(title: "No Flight",
                                         message: "No flights were found to list in this selection.")
            }
            if !state.items.isEmpty { self.didShowEmptyOnce = false }
        }
    }

    // MARK: - Actions
    @objc private func segChanged() {
        let f: LaunchFilter = (segmented.selectedSegmentIndex == 0) ? .upcoming : .previous
        viewModel.setFilter(f)
        collectionView.setContentOffset(.zero, animated: false)
        // ufak haptic
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @objc private func didPullToRefresh() {
        viewModel.reload()
    }

    // MARK: - Alert helper
    private func presentOneShotAlert(title: String, message: String) {
        guard !isPresentingAlert, presentedViewController == nil else { return }
        isPresentingAlert = true
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Close", style: .default) { [weak self] _ in
            self?.isPresentingAlert = false
        })
        present(a, animated: true)
    }

    // Gradient ve yıldızların frame’ini güncel tut
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient?.frame = view.bounds
        starfield?.emitterPosition = CGPoint(x: view.bounds.midX, y: -4)
        starfield?.emitterSize = CGSize(width: view.bounds.width, height: 1)
    }
}

// MARK: - Data Source
extension LaunchListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.state.items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LaunchCell.reuseID,
            for: indexPath
        ) as! LaunchCell

        let items = viewModel.state.items
        guard indexPath.item < items.count else { return cell }

        cell.configure(with: items[indexPath.item])
        viewModel.loadNextPageIfNeeded(currentIndex: indexPath.item)
        return cell
    }
}

// MARK: - FlowLayout Delegate (genişlik kilidi)
extension LaunchListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flow = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let insets = flow.sectionInset
        let adjusted = collectionView.adjustedContentInset
        let width = collectionView.bounds.width - insets.left - insets.right - adjusted.left - adjusted.right
        // self-sizing yükseklik için h=1 hilesi
        return CGSize(width: max(0, width), height: 1)
    }

    // Hücreleri kozmik kartlara çevir
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Yalın, ağır olmayan stil: koyu kart + ince çerçeve + hafif gölge
        cell.contentView.backgroundColor = Theme.cardFill
        cell.contentView.layer.cornerRadius = 16
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.borderColor = Theme.cardStroke.cgColor
        cell.contentView.layer.borderWidth = 1

        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.35
        cell.layer.shadowRadius = 10
        cell.layer.shadowOffset = CGSize(width: 0, height: 6)
        cell.layer.masksToBounds = false

        // Seçim geri bildirimi
        let selectedBG = UIView()
        selectedBG.backgroundColor = Theme.accentSoft
        selectedBG.layer.cornerRadius = 16
        cell.selectedBackgroundView = selectedBG
    }
}

// MARK: - Delegate (seçim → detay)
extension LaunchListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard indexPath.item >= 0, indexPath.item < viewModel.state.items.count else { return }
        guard let flight = viewModel.launch(at: indexPath.item) else { return }

        let detailVC = LaunchDetailViewController()
        detailVC.viewModel = LaunchDetailViewModel(flight: flight)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
