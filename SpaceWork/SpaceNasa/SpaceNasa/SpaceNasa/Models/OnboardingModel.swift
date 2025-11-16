//
//  Onboarding.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 12.10.2025.
//

import Foundation

public struct OnboardingBullet: Hashable {
    public let text: String
    public init(text: String) { self.text = text }
}

public struct OnboardingPage: Hashable {
    public let heroImageName: String
    public let title: String
    public let subtitle: String
    public let bullets: [OnboardingBullet]
    public init(heroImageName: String, title: String, subtitle: String, bullets: [OnboardingBullet]) {
        self.heroImageName = heroImageName
        self.title = title
        self.subtitle = subtitle
        self.bullets = bullets
    }
}

// Kalıcılık soyutlaması
public protocol OnboardingPersistence {
    var hasSeen: Bool { get set }
}

public struct UserDefaultsOnboardingPersistence: OnboardingPersistence {
    private let key = "hasSeenOnboarding"
    public init() {}
    public var hasSeen: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
