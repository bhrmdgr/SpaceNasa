//
//  DashboardViewModel.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 7.10.2025.
//

import Foundation
import SpaceNasaAPI

enum DashboardState: Equatable {
    case idle
    case loading
    case content(DashboardViewData)
    case error(String)
}

protocol DashboardViewModelProtocol: AnyObject {
    var onStateChange: ((DashboardState) -> Void)? { get set }
    func load(programId: Int)
}

@MainActor
final class DashboardViewModel: DashboardViewModelProtocol {

    private let programService: ProgramServiceProtocol
    private let flightService: FlightServiceProtocol

    var onStateChange: ((DashboardState) -> Void)?

    private var program: Program?
    private var metrics: ProgramMetrics?

    init(programService: ProgramServiceProtocol = ProgramService(),
         flightService: FlightServiceProtocol = FlightService()) {
        self.programService = programService
        self.flightService = flightService
    }

    func load(programId: Int) {
        onStateChange?(.loading)

        // Completion ana aktör dışında dönebilir, girer girmez Main'e hopla.
        programService.fetchProgram(id: programId) { [weak self] progResult in
            Task { @MainActor [weak self] in
                guard let self else { return }

                switch progResult {
                case .failure(let err):
                    onStateChange?(.error(err.localizedDescription))

                case .success(let prog):
                    // MainActor
                    self.program = prog
                    let interim = DashboardModel.map(program: prog, metrics: nil)
                    self.onStateChange?(.content(interim))

                    // Metrikleri iste ve yine Main'e hoplayarak güncelle
                    self.fetchMetricsAndUpdate(programId: programId, prog: prog, interim: interim)
                }
            }
        }
    }

    private func fetchMetricsAndUpdate(programId: Int, prog: Program, interim: DashboardViewData) {
        flightService.fetchProgramMetrics(programId: programId) { [weak self] metResult in
            Task { @MainActor [weak self] in
                guard let self else { return }

                switch metResult {
                case .failure:
                    // metrik gelmese de mevcut içerik kalsın
                    self.onStateChange?(.content(interim))

                case .success(let m):
                    self.metrics = m
                    let vd = DashboardModel.map(program: prog, metrics: m)
                    self.onStateChange?(.content(vd))
                }
            }
        }
    }
}
