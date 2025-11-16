//
//  ProgramService.swift
//  SpaceNasaAPI
//
//  Created by Behram Doğru on 6.10.2025.
//

import Foundation
import Alamofire

public protocol ProgramServiceProtocol {
    func fetchPrograms(limit: Int, completion: @escaping @Sendable (Result<[Program], Error>) -> Void)
    func fetchProgram(id: Int, completion: @escaping @Sendable (Result<Program, Error>) -> Void)
}

public final class ProgramService: ProgramServiceProtocol {
    public init() {}

    // MARK: Home ekranı için
    public func fetchPrograms(
        limit: Int = 100,
        completion: @escaping @Sendable (Result<[Program], Error>) -> Void
    ) {
        let url = "https://lldev.thespacedevs.com/2.2.0/program/?limit=\(limit)&format=json"

        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = Decoders.dateDecoders
                    let payload = try decoder.decode(ProgramResults.self, from: data)
                    completion(.success(payload.results))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: Dashboard için
    public func fetchProgram(
        id: Int,
        completion: @escaping @Sendable (Result<Program, Error>) -> Void
    ) {
        let url = "https://lldev.thespacedevs.com/2.2.0/program/\(id)/?limit=100&format=json"

        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = Decoders.dateDecoders
                    let program = try decoder.decode(Program.self, from: data)
                    completion(.success(program))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
