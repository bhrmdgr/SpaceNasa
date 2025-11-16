//
//  Decoders.swift
//  SpaceNasaAPI
//
//  Created by Behram Doğru on 5.10.2025.
//

import Foundation

public enum Decoders {
    
    // .iso8601 geldiği gibi döndürmemize yarıyor.
    
    static let dateDecoders: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return decoder
    }()
}
