//
//  Home.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 5.10.2025.
//

import Foundation
import SpaceNasaAPI

struct ProgramItemViewData: Hashable {
    let id: Int
    let title: String
    let imageURL: URL?
}

enum HomeModel {
    static func map(_ programs: [Program]) -> [ProgramItemViewData] {
        programs.map {
            ProgramItemViewData(
                id: $0.id,
                title: $0.name,
                imageURL: $0.imageUrl.flatMap(URL.init(string:))
            )
        }
    }
}

