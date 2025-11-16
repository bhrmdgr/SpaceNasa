//
//  LaunchFilter.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 10.10.2025.
//

enum LaunchFilter {
    case upcoming, previous
    var pathSegment: String { self == .upcoming ? "upcoming" : "previous" }
    var ordering: String { self == .upcoming ? "net" : "-net" }
    var title: String { self == .upcoming ? "Yaklaşan" : "Gerçekleşen" }
}
