//
//  DashBoard.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 11.10.2025.
//

// DashboardScreenModel.swift
import Foundation
import SpaceNasaAPI

struct DashboardViewData: Equatable {

    let title: String?
    let description: String?
    let imageURL: URL?

    // Metrikler
    let flightCountText: String?
    let successRateText: String?
    let isApprox: Bool
}

enum DashboardModel {

    // Ortak sayı/percent formatlayıcıları
    private static let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()

    private static let percentFormatter: NumberFormatter = {
        let pf = NumberFormatter()
        pf.numberStyle = .percent
        pf.maximumFractionDigits = 0
        return pf
    }()

    /// Program + Metrics -> ViewData
    static func map(program: Program, metrics: ProgramMetrics?) -> DashboardViewData {
        let imageURL = program.imageUrl.flatMap(URL.init(string:))

        // Uçuş sayısı
        let flightText: String?
        if let total = metrics?.totalFlights {
            let n = numberFormatter.string(from: NSNumber(value: total)) ?? "\(total)"
            flightText = "Launch Count: \(n)"
        } else {
            flightText = nil
        }

        // Başarı oranı
        let successText: String?
        if let rate = metrics?.successRate {
            let p = percentFormatter.string(from: NSNumber(value: rate)) ?? "\(Int(rate * 100))%"
            successText = "Success Rate: \(p)"
        } else {
            successText = nil
        }

        return DashboardViewData(
            title: program.name,
            description: program.description,
            imageURL: imageURL,
            flightCountText: flightText,
            successRateText: successText,
            isApprox: false 
        )

    }
}
