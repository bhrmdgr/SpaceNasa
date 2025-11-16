//
//  HomeViewModel.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 5.10.2025.
//

import Foundation
import SpaceNasaAPI

enum HomeState: Equatable {
    case idle
    case loading
    case loaded([ProgramItemViewData])
    case error(String)
}

enum HomeRoute: Equatable {
    case dashboard(programId: Int, title: String)
}

protocol HomeViewModelProtocol: AnyObject {
    var onChange: ((HomeState) -> Void)? { get set }
    var onRoute: ((HomeRoute) -> Void)? { get set }
    func load(limit: Int)
    func numberOfItems() -> Int
    func item(at index: Int) -> ProgramItemViewData?
    func didSelectItem(at index: Int)
}

@MainActor
final class HomeViewModel: HomeViewModelProtocol {

    private let programService: ProgramServiceProtocol
    private var items: [ProgramItemViewData] = []

    var onChange: ((HomeState) -> Void)?
    var onRoute: ((HomeRoute) -> Void)?

    init(programService: ProgramServiceProtocol = ProgramService()) {
        self.programService = programService
    }

    func load(limit: Int = 100) {
        onChange?(.loading)

        programService.fetchPrograms(limit: limit) { [weak self] result in
            // completion @Sendable olabilir; ana aktöre güvenli şekilde dön.
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case .success(let programs):
                    // Görünüm veri modeli (ana aktörde)
                    let mapped = HomeModel.map(Array(programs.reversed()))
                    self.items = mapped
                    self.onChange?(.loaded(mapped))

                case .failure(let error):
                    self.items = []
                    self.onChange?(.error(error.localizedDescription))
                }
            }
        }
    }

    func numberOfItems() -> Int { items.count }

    func item(at index: Int) -> ProgramItemViewData? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }

    func didSelectItem(at index: Int) {
        guard let item = item(at: index) else { return }
        onRoute?(.dashboard(programId: item.id, title: item.title))
    }
}
