//
//  Program.swift
//  SpaceNasaAPI
//
//  Created by Behram Doğru on 6.10.2025.
//

import Foundation

public struct Program: Decodable, Hashable , Sendable {
    public let id: Int
    public let name: String
    public let imageUrl: String?
    public let description: String?


    enum CodingKeys: String, CodingKey {
        case id, name, description
        case imageUrl = "image_url"
    }

    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public static func == (lhs: Program, rhs: Program) -> Bool { lhs.id == rhs.id }
}

public struct ProgramResults: Decodable , Sendable {
    public let count: Int?
    public let next: URL?
    public let previous: URL?
    public let results: [Program]
}
