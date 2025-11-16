//
//  FlightService.swift
//  SpaceNasaAPI
//
//  Created by Behram Doğru on 5.10.2025.
//

import Foundation
import Alamofire


fileprivate let ENABLE_LOGS = false // Log görüntülemek için

@inline(__always) fileprivate func log(_ items: Any...) {
    guard ENABLE_LOGS else { return }
    let line = items.map { String(describing: $0) }.joined(separator: " ")
    print(line)
}

// MARK: Metrik modeli
public struct ProgramMetrics: Sendable {
    public let totalFlights: Int
    public let pastFlights: Int
    public let successFlights: Int

    public var successRate: Double? {
        pastFlights > 0 ? Double(successFlights) / Double(pastFlights) : nil
    }
}


// MARK: - Liste türü
public enum LaunchListType {
    case upcoming
    case previous

    var pathSegment: String { self == .upcoming ? "upcoming" : "previous" }
    /// En yakın tarih üstte olacak sıralama
    var ordering: String { self == .upcoming ? "net" : "-net" }
}

// MARK: - Protokol
public protocol FlightServiceProtocol {
    func fetchFlights(completion: @escaping @Sendable (Result<[Flight], Error>) -> Void)

    func fetchProgramMetrics(
        programId: Int,
        completion: @escaping @Sendable (Result<ProgramMetrics, Error>) -> Void
    )

    // Programa göre uçuş listesi
    func listLaunches(
        programId: Int,
        type: LaunchListType,
        limit: Int,
        offset: Int?,
        completion: @escaping @Sendable (Result<FlightResults, Error>) -> Void
    )

    func fetchFlight(
        id: String,
        mode: String,
        completion: @escaping @Sendable (Result<Flight, Error>) -> Void
    )
}

// MARK: - Servis
public final class FlightService: FlightServiceProtocol {

    let base = "https://lldev.thespacedevs.com/2.2.0"

    public init() {}

    public func fetchFlights(completion: @escaping @Sendable (Result<[Flight], Error>) -> Void) {
        let url = "\(base)/launch/upcoming/?format=json&mode=list&limit=20"

        AF.request(url)
            .validate()
            .responseDecodable(of: FlightResults.self, decoder: Decoders.dateDecoders) { res in
                switch res.result {
                case .success(let payload):
                    completion(.success(payload.results))
                case .failure(let err):
                    if let data = res.data, let body = String(data: data, encoding: .utf8) {
                        log("⛔️ fetchFlights error:", err.localizedDescription)
                        log("🧾 body:", body.prefix(4000))
                    } else {
                        log("⛔️ fetchFlights error:", err.localizedDescription)
                    }
                    completion(.failure(err))
                }
            }
    }

    public func fetchFlight(
        id: String,
        mode: String = "detailed",
        completion: @escaping @Sendable (Result<Flight, Error>) -> Void
    ) {
        let url = "\(base)/launch/\(id)/?format=json&mode=\(mode)"
        AF.request(url)
            .validate()
            .responseDecodable(of: Flight.self, decoder: Decoders.dateDecoders) { res in
                switch res.result {
                case .success(let flight):
                    completion(.success(flight))
                case .failure(let err):
                    if let data = res.data, let body = String(data: data, encoding: .utf8) {
                        log("⛔️ fetchFlight error:", err.localizedDescription)
                        log("🧾 body:", body.prefix(4000))
                    } else {
                        log("⛔️ fetchFlight error:", err.localizedDescription)
                    }
                    completion(.failure(err))
                }
            }
    }

    public func listLaunches(
        programId: Int,
        type: LaunchListType,
        limit: Int,
        offset: Int?,
        completion: @escaping @Sendable (Result<FlightResults, Error>) -> Void
    ) {
        var comps = URLComponents(string: "\(base)/launch/\(type.pathSegment)/")!
        var items: [URLQueryItem] = [
            .init(name: "program", value: String(programId)),
            .init(name: "mode", value: "list"),
            .init(name: "limit", value: String(limit)),
            .init(name: "ordering", value: type.ordering),
            .init(name: "format", value: "json")
        ]
        if let offset {
            items.append(.init(name: "offset", value: String(offset)))
        }
        comps.queryItems = items

        let url = comps.url!

        AF.request(url)
            .validate()
            .responseDecodable(of: FlightResults.self, decoder: Decoders.dateDecoders) { res in
                switch res.result {
                case .success(let payload):
                    log("✅ listLaunches ok: results=\(payload.results.count) next=\(String(describing: payload.next))")
                    completion(.success(payload))

                case .failure(let err):
                    log("⛔️ listLaunches error:", err.localizedDescription)
                    if let data = res.data, let body = String(data: data, encoding: .utf8) {
                        log("🧾 body:", body.prefix(4000))
                    }
                    completion(.failure(err))
                }
            }
    }

    // MARK: - Swift 6-safe ardışık metrik toplama (paylaşılan var mutasyonu yok)
    public func fetchProgramMetrics(
        programId: Int,
        completion: @escaping @Sendable (Result<ProgramMetrics, Error>) -> Void
    ) {
        let nowISO: String = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime]
            return f.string(from: Date())
        }()

        // Tüm uçuşlar
        fetchLaunchCount(programId: programId, extra: []) { [weak self] totalResult in
            guard let self else { return }
            switch totalResult {
            case .failure(let err):
                completion(.failure(err))

            case .success(let totalAll):
                // Tüm Geçmiş Uçuşlar
                self.fetchLaunchCount(
                    programId: programId,
                    extra: [.init(name: "net__lt", value: nowISO)]
                ) { pastResult in
                    switch pastResult {
                    case .failure(let err):
                        completion(.failure(err))

                    case .success(let pastTotal):
                        // Geçmişteki başarılı uçuşlar
                        self.fetchLaunchCount(
                            programId: programId,
                            extra: [
                                .init(name: "net__lt", value: nowISO),
                                .init(name: "status",  value: "3")
                            ]
                        ) { successResult in
                            switch successResult {
                            case .failure(let err):
                                completion(.failure(err))
                            case .success(let pastSuccess):
                                completion(.success(.init(
                                    totalFlights: totalAll,
                                    pastFlights: pastTotal,
                                    successFlights: pastSuccess
                                )))
                            }
                        }
                    }
                }
            }
        }
    }

}

// MARK: Sadece Count Bilgisi için
public extension FlightService {
    func fetchLaunchCount(
        programId: Int,
        extra: [URLQueryItem] = [],
        completion: @escaping @Sendable (Result<Int, Error>) -> Void
    ) {
        var comps = URLComponents(string: "\(base)/launch/")!
        var items: [URLQueryItem] = [
            .init(name: "program", value: String(programId)),
            .init(name: "limit", value: "1"),
            .init(name: "format", value: "json")
        ]
        items.append(contentsOf: extra)
        comps.queryItems = items

        struct CountDTO: Decodable { let count: Int }

        AF.request(comps.url!)
            .validate()
            .responseDecodable(of: CountDTO.self) { res in
                switch res.result {
                case .success(let dto):
                    completion(.success(dto.count))
                case .failure(let err):
                    log("⛔️ fetchLaunchCount error:", err.localizedDescription)
                    completion(.failure(err))
                }
            }
    }
}

extension FlightService: @unchecked Sendable {}
