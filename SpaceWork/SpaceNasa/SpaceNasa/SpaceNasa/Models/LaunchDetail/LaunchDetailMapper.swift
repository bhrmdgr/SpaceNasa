//
//  LaunchDetailMapper.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 10.10.2025.
//


import Foundation
import SpaceNasaAPI

enum LaunchDetailMapper {

    static func map(_ flight: Flight,
                    locale: Locale = .current,
                    timeZone: TimeZone = .current) -> LaunchDetailViewData {

        // Durum
        let statusText: String? = firstNonEmpty(flight.status?.abbrev, flight.status?.name)
        let statusDescription: String? = trimmedOrNil(flight.status?.description)

        // Zaman
        let netText: String? = formatNET(flight.net, locale: locale, timeZone: timeZone)

        // Görsel
        let imageURL: URL? = flight.image.flatMap(URL.init(string:))

        // Yer
        let padName: String? = trimmedOrNil(flight.pad)
        let siteName: String? = trimmedOrNil(flight.location)
        let countryCode: String? = firstNonEmpty(flight.countryCode, extractCountryCode(from: flight.location))

        // Sağlayıcı
        let providerName: String? = trimmedOrNil(flight.lspName)
        let providerType: String? = trimmedOrNil(flight.providerType)

        // Roket
        let rocketFullName: String? = trimmedOrNil(flight.rocketFullName)
        let rocketFamily: String? = trimmedOrNil(flight.rocketFamily)
        let rocketVariant: String? = trimmedOrNil(flight.rocketVariant)

        // Görev
        let missionName: String? = trimmedOrNil(flight.missionName)
        let missionType: String? = trimmedOrNil(flight.missionType)
        let missionOrbit: String? = trimmedOrNil(flight.missionOrbit)
        let missionDescription: String? = trimmedOrNil(flight.missionDescription)

        return LaunchDetailViewData(
            title: flight.name,
            statusText: statusText,
            statusDescription: statusDescription,
            netText: netText,
            imageURL: imageURL,
            rocketFullName: rocketFullName,
            rocketFamily: rocketFamily,
            rocketVariant: rocketVariant,
            missionName: missionName,
            missionType: missionType,
            missionOrbit: missionOrbit,
            missionDescription: missionDescription,
            padName: padName,
            siteName: siteName,
            countryCode: countryCode,
            providerName: providerName,
            providerType: providerType
        )
    }

    // MARK: - Helpers

    static func formatNET(_ iso8601String: String?, locale: Locale, timeZone: TimeZone) -> String? {
        guard let iso = trimmedOrNil(iso8601String) else { return nil }
        let optionsList: [ISO8601DateFormatter.Options] = [
            [.withInternetDateTime, .withFractionalSeconds],
            [.withInternetDateTime]
        ]
        for opts in optionsList {
            let parser = ISO8601DateFormatter()
            parser.timeZone = TimeZone(secondsFromGMT: 0)
            parser.formatOptions = opts
            if let date = parser.date(from: iso) {
                let f = DateFormatter()
                f.locale = locale
                f.timeZone = timeZone
                f.dateStyle = .medium
                f.timeStyle = .short
                return f.string(from: date)
            }
        }
        return iso
    }

    static func extractCountryCode(from locationText: String?) -> String? {
        guard let text = trimmedOrNil(locationText) else { return nil }
        let parts = text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return parts.last
    }

    private static func firstNonEmpty(_ values: String?...) -> String? {
        for val in values { if let t = trimmedOrNil(val) { return t } }
        return nil
    }

    private static func trimmedOrNil(_ text: String?) -> String? {
        guard let t = text?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
        return t
    }
}
