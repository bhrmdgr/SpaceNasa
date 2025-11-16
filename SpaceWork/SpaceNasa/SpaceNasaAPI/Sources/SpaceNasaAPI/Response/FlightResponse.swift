//
//  FlightsResponse.swift
//  SpaceNasaAPI
//
//  Created by Behram Doğru on 5.10.2025.
//

import Foundation

public struct FlightResponse: Decodable, Sendable {
    public let count: Int?
    public let next: URL?
    public let previous: URL?
    public let results: [Flight]

    private enum CodingKeys: String, CodingKey {
        case count, next, previous, results
    }
}
