//
//  LaunchListViewModel.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 4.10.2025.
//

//
//  LaunchListViewModel.swift
//  SpaceNasa
//

import Foundation
import SpaceNasaAPI

// MARK: - Protocol
protocol LaunchListViewModelProtocol: AnyObject {
    var onStateChange: ((LaunchListState) -> Void)? { get set }
    var state: LaunchListState { get }
    func configure(programId: Int)
    func setFilter(_ filter: LaunchFilter)
    func reload()
    func loadNextPageIfNeeded(currentIndex: Int)
    func launch(at index: Int) -> Flight?
}

// MARK: - ViewModel
@MainActor
final class LaunchListViewModel: LaunchListViewModelProtocol {

    private let flightService: FlightServiceProtocol

    private let pageSize = 20
    private let prefetchThreshold = 5

    private var programId: Int!
    private var filter: LaunchFilter = .upcoming
    private var isLoading = false
    private var nextOffset: Int? = 0

    private(set) var state = LaunchListState() {
        didSet { onStateChange?(state) }
    }
    var onStateChange: ((LaunchListState) -> Void)?

    init(flightService: FlightServiceProtocol = FlightService()) {
        self.flightService = flightService
    }

    // MARK: Config
    func configure(programId: Int) {
        self.programId = programId
    }

    func setFilter(_ filter: LaunchFilter) {
        guard self.filter != filter else { return }
        self.filter = filter
        reload()
    }

    // MARK: Reload
    func reload() {
        guard programId != nil else { return }
        nextOffset = 0
        isLoading = true
        state = .init(isLoading: true, items: [], errorMessage: nil, shouldShowEmptyAlert: false)
        fetchPage(offset: 0)
    }

    func loadNextPageIfNeeded(currentIndex: Int) {
        guard currentIndex >= state.items.count - prefetchThreshold,
              let next = nextOffset,
              !isLoading else { return }
        isLoading = true
        fetchPage(offset: next, append: true)
    }

    // MARK: Select Helper
    func launch(at index: Int) -> Flight? {
        let items = state.items
        guard index >= 0, index < items.count else { return nil }
        return items[index].flight
    }

    // MARK: Networking
    private func fetchPage(offset: Int, append: Bool = false) {
        let type: LaunchListType = (filter == .upcoming) ? .upcoming : .previous

        flightService.listLaunches(programId: programId,
                                   type: type,
                                   limit: pageSize,
                                   offset: offset) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let payload):
                    // next offset
                    self.nextOffset = LaunchListModel.extractOffset(from: payload.next)

                    // DTO -> Item
                    let mapped = payload.results.map(LaunchListModel.map)

                    // Filtre + sırala
                    let sorted = LaunchListModel.filterAndSort(mapped, by: self.filter)

                    // Birleştir
                    let items = append
                        ? LaunchListModel.mergeDedup(existing: self.state.items, new: sorted)
                        : sorted

                    self.state.isLoading = false
                    self.state.items = items
                    self.state.errorMessage = nil
                    self.state.shouldShowEmptyAlert = items.isEmpty

                case .failure(let error):
                    self.nextOffset = nil
                    self.state.isLoading = false
                    self.state.errorMessage = (error as NSError).localizedDescription
                    self.state.shouldShowEmptyAlert = false
                }
            }
        }
    }
}
