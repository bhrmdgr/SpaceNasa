//
//  OnboardingViewModel.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 12.10.2025.
//

import Foundation

public struct OnboardingState: Equatable {
    public var pages: [OnboardingPage] = []
    public var currentPage: Int = 0
    public var isFinished: Bool = false
    public init() {}
}

public protocol OnboardingViewModelProtocol: AnyObject {
    var onChange: ((OnboardingState) -> Void)? { get set }
    var state: OnboardingState { get }
    func load()
    func setPage(_ index: Int)
    func skip()
}

public final class OnboardingViewModel: OnboardingViewModelProtocol {
    private let persistence: OnboardingPersistence
    public private(set) var state = OnboardingState() { didSet { onChange?(state) } }
    public var onChange: ((OnboardingState) -> Void)?

    public init(persistence: OnboardingPersistence = UserDefaultsOnboardingPersistence()) {
        self.persistence = persistence
    }

    public func load() {
        state.pages = [
            .init(
                heroImageName: "1.jpg",
                title: "All Launches, One Place",
                subtitle: "A single timeline for every agency and provider. Scan what's next, what's rolling, and what's slipped—without hopping between sources.",
                bullets: [
                    .init(text: "Unified feed of upcoming and past launches"),
                    .init(text: "Filter by agency, vehicle, pad, or date"),
                    .init(text: "Clean cards with images and key facts")
                ]
            ),
            .init(
                heroImageName: "2.jpg",
                title: "Jump Into Your Program",
                subtitle: "Open a program and instantly see its live and upcoming launches—focused on what you care about.",
                bullets: [
                    .init(text: "Program-scoped feed with real-time status"),
                    .init(text: "Quick access to provider, pad and NET time"),
                    .init(text: "One tap from program to launch details")
                ]
            ),
            .init(
                heroImageName: "3.jpg",
                title: "Real-Time, Zero Friction",
                subtitle: "Statuses, NET times and details update as they change, so you get the truth at T-0—not stale screenshots.",
                bullets: [
                    .init(text: "Live status chips (Hold, TBD, Go) and reasons"),
                    .init(text: "Human-readable local times and time-zone aware"),
                    .init(text: "Compact sections to reach the right fact fast")
                ]
            )
        ]
        onChange?(state)
    }

    public func setPage(_ index: Int) {
        guard index >= 0, index < state.pages.count else { return }
        state.currentPage = index
    }

    public func skip() {
        var s = state
        s.isFinished = true
        state = s
        var p = persistence; p.hasSeen = true
    }
}
