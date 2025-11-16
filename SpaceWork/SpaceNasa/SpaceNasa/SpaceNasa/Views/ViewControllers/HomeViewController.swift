//
//  HomeViewController.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 5.10.2025.
//

import UIKit

final class HomeViewController: UIViewController, LoadingShowable {

    // MARK: - UI
    @IBOutlet weak var collectionView: UICollectionView!
    private let viewModel: HomeViewModelProtocol = HomeViewModel()

    private let headerHeight: CGFloat = 240
    private let headerImageAssetName = "nasa.png"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasics()
        setBackgroundImage(named: "background.jpg", dimAlpha: 0.20)
        setupCollection()
        bind()
        viewModel.load(limit: 100)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Setup
    private func setupBasics() {
        view.backgroundColor = .black
    }

    private func setupCollection() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = nil
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: FlightProgramCell.self)
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        
                collectionView.register(MissionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MissionHeaderView.reuseID)

        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.sectionHeadersPinToVisibleBounds = false
        }
    }

    // MARK: - Bind
    private func bind() {
        viewModel.onChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .idle: break
            case .loading:
                self.showLoading()
            case .loaded:
                self.hideLoading()
                self.collectionView.reloadData()
            case .error(let msg):
                self.hideLoading()
                print("Error:", msg)
            }
        }

        viewModel.onRoute = { [weak self] route in
            guard let self else { return }
            switch route {
            case .dashboard(let programId, let title):
                let vc = DashboardViewController()
                vc.programId = programId
                vc.title = title
                vc.hidesBottomBarWhenPushed = true
                (self.navigationController ?? self).show(vc, sender: self)
            }
        }
    }
}

// MARK: - DataSource
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FlightProgramCell = collectionView.dequeCell(
            cellType: FlightProgramCell.self,
            indexPath: indexPath
        )
        if let data = viewModel.item(at: indexPath.item) {
            cell.configure(with: data)
        }
        return cell
    }

    // Header (scroll ile kaybolur)
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MissionHeaderView.reuseID,
            for: indexPath
        ) as! MissionHeaderView

        header.configure(
            image: UIImage(named: headerImageAssetName),
            title: "Pick the program you’re interested in.",
            subtitle: ""
        )
        return header
    }
}

// MARK: - Delegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        viewModel.didSelectItem(at: indexPath.item)
    }

    // Header fade out
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerHeight: CGFloat = self.headerHeight
        let y = scrollView.contentOffset.y
        if y >= 0 && y <= headerHeight {
            let progress = min(max(y / headerHeight, 0), 1)
            for v in collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader) {
                v.alpha = 1 - progress
            }
        }
    }
}

// MARK: - FlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: headerHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 2
        let spacing: CGFloat = 12
        let totalSpacing = (columns - 1) * spacing + collectionView.contentInset.left + collectionView.contentInset.right
        let width = (collectionView.bounds.width - totalSpacing) / columns

        let imageRatio: CGFloat = 0.62 // ~16:10
        let titleHeight: CGFloat = 56
        let height = (width * imageRatio) + 12 + titleHeight + 10
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 12 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 12 }
}

// MARK: - Private header view (aynı dosyada)
private final class MissionHeaderView: UICollectionReusableView {

    static let reuseID = "MissionHeaderView"

    private let imageView = UIImageView()
    private let dimView = UIView()
    private let gradient = CAGradientLayer()

    private let stack = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }

    private func build() {
        backgroundColor = .clear

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Okunabilirlik için hafif dim
        dimView.backgroundColor = UIColor(white: 0, alpha: 0.25)
        dimView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(dimView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // Üste hafif gradient (status bar hizasında koyuluk)
        gradient.colors = [
            UIColor(white: 0, alpha: 0.45).cgColor,
            UIColor(white: 0, alpha: 0.10).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0.0, 0.35, 0.8]
        layer.addSublayer(gradient)

        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        if let rounded = UIFont.systemFont(ofSize: 16, weight: .black).withDesign(.rounded) {
            titleLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: rounded)
        } else {
            titleLabel.font = .systemFont(ofSize: 16, weight: .black)
        }
        titleLabel.layer.shadowColor = UIColor(displayP3Red: 0.0, green: 0.82, blue: 0.92, alpha: 1.0).cgColor
        titleLabel.layer.shadowOpacity = 0.35
        titleLabel.layer.shadowRadius = 8
        titleLabel.layer.shadowOffset = .zero
        titleLabel.adjustsFontForContentSizeCategory = true

        subtitleLabel.textColor = UIColor(white: 0.90, alpha: 1)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        if let rounded = UIFont.systemFont(ofSize: 15, weight: .semibold).withDesign(.rounded) {
            subtitleLabel.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: rounded)
        } else {
            subtitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        }
        subtitleLabel.adjustsFontForContentSizeCategory = true

        // Stack — alt kısma yakın, yatay ORTA
        stack.axis = .vertical
        stack.alignment = .center           
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)

        addSubview(stack)

        // Alt kısma yakın ve yatay ortada konumlandır
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            // Güvenli kenarlar: çok uzun metinde taşmayı engelle
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    func configure(image: UIImage?, title: String, subtitle: String) {
        imageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

// MARK: - Small helper
private extension UIFont {
    func withDesign(_ design: UIFontDescriptor.SystemDesign) -> UIFont? {
        fontDescriptor.withDesign(design).map { UIFont(descriptor: $0, size: pointSize) }
    }
}
