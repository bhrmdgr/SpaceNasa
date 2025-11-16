//
//  ProgramResponse.swift
//  SpaceNasaAPI
//
//  Created by Behram Doğru on 6.10.2025.
//
import Foundation

struct ProgramsResponse: Decodable , Sendable {
    let results: [Program]

    private enum CodingKeys: String, CodingKey { case results }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.results = try container.decode([Program].self, forKey: .results)
    }
}
