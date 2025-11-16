//
//  Launchdetail.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 4.10.2025.
//


import Foundation

struct LaunchDetailViewData: Equatable {
    // Başlık
    let title: String
    let statusText: String?
    let statusDescription: String?

    // Zamanlama
    let netText: String?

    // Görsel
    let imageURL: URL?

    // Roket
    let rocketFullName: String?
    let rocketFamily: String?
    let rocketVariant: String?

    // Görev
    let missionName: String?
    let missionType: String?
    let missionOrbit: String?
    let missionDescription: String?

    // Fırlatma yeri
    let padName: String?
    let siteName: String?
    let countryCode: String?

    // Sağlayıcı
    let providerName: String?
    let providerType: String?
}
