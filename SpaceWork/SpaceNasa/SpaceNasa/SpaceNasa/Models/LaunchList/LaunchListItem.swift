//
//  LaunchListItem.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 10.10.2025.
//
//
//  LaunchListItem.swift
//  SpaceNasa
//

import Foundation
import SpaceNasaAPI   // Flight için gerekli

struct LaunchListItem: Equatable, Hashable {
    let id: String
    let name: String
    let net: Date?
    let netText: String
    let rocketName: String?
    let locationName: String?
    let statusAbbrev: String?
    let imageURL: URL?

    // Detay ekranına ham DTO ile geçiş için
    let flight: Flight

    // Eşitlik: yalnıza id
    static func == (lhs: LaunchListItem, rhs: LaunchListItem) -> Bool {
        lhs.id == rhs.id
    }

    // Hash: yalnıza id
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
