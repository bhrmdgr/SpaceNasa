//
//  LaunchDetailViewModel.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 4.10.2025.
//


import Foundation
import SpaceNasaAPI

struct LaunchDetailState: Equatable {
    var isLoading: Bool = false
    var data: LaunchDetailViewData?
    var errorMessage: String?
}

protocol LaunchDetailViewModelProtocol: AnyObject {
    var onStateChange: ((LaunchDetailState) -> Void)? { get set }
    func viewDidLoad()
}

@MainActor
final class LaunchDetailViewModel: LaunchDetailViewModelProtocol {

    var onStateChange: ((LaunchDetailState) -> Void)?

    private let initialFlight: Flight
    private let service: FlightServiceProtocol

    private(set) var state = LaunchDetailState() {
        didSet { onStateChange?(state) }
    }
    

    init(flight: Flight, service: FlightServiceProtocol = FlightService()) {
        self.initialFlight = flight
        self.service = service
    }

    
    func viewDidLoad() {
        // İlk boyama
        state.isLoading = true
        let firstData = LaunchDetailMapper.map(initialFlight)
        state = .init(isLoading: false, data: firstData, errorMessage: nil)

        // Detay enrichment (roket/mission vs. kesin gelsin)
        fetchDetailed()
    }

    
    private func fetchDetailed() {
        state.isLoading = true
        service.fetchFlight(id: initialFlight.id, mode: "detailed") { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case .success(let detailed):
                    let enriched = LaunchDetailMapper.map(detailed)
                    self.state = .init(isLoading: false, data: enriched, errorMessage: nil)
                case .failure(let error):
                    // İlk veriyi koru
                    self.state = .init(isLoading: false, data: self.state.data,
                                       errorMessage: (error as NSError).localizedDescription)
                }
            }
        }
    }
}
