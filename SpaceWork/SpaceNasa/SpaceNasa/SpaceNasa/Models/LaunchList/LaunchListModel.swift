//
//  Launch.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 4.10.2025.
//


import Foundation
import SpaceNasaAPI

/// LaunchList ekranı için veri dönüştürme yardımcıları.
/// Thread-safe ve MainActor bağımsız.
enum LaunchListModel {

    // MARK: - Public API

    static func map(_ flight: Flight) -> LaunchListItem {
        let netDate = parseNetDate(from: flight.net)
        let netText = formatNetDate(netDate)

        let imageURL = sanitizeURLString(flight.image)
        let rocketName = flight.lspName
        let locationName = flight.location ?? flight.pad

        return LaunchListItem(
            id: flight.id,
            name: flight.name,
            net: netDate,
            netText: netText,
            rocketName: rocketName,
            locationName: locationName,
            statusAbbrev: flight.status?.abbrev,
            imageURL: imageURL,
            flight: flight
        )
    }

    static func map(_ flights: [Flight]) -> [LaunchListItem] {
        flights.map { map($0) }
    }

    static func filterAndSort(_ items: [LaunchListItem],
                              by filter: LaunchFilter,
                              now: Date = Date()) -> [LaunchListItem] {
        let filtered = items.filter { item in
            guard let date = item.net else { return filter == .previous }
            return filter == .upcoming ? (date >= now) : (date < now)
        }

        let ascending = filtered.sorted { ($0.net ?? .distantFuture) < ($1.net ?? .distantFuture) }
        return filter == .upcoming ? ascending : ascending.reversed()
    }

    static func mergeDedup(existing existingItems: [LaunchListItem],
                           new newItems: [LaunchListItem]) -> [LaunchListItem] {
        var seen = Set(existingItems.map(\.id))
        var merged = existingItems
        for item in newItems where !seen.contains(item.id) {
            merged.append(item)
            seen.insert(item.id)
        }
        return merged
    }

    static func extractOffset(from next: Any?) -> Int? {
        if let url = next as? URL {
            return extractOffset(from: url)
        }
        if let string = next as? String, let url = URL(string: string) {
            return extractOffset(from: url)
        }
        return nil
    }

    private static func extractOffset(from url: URL) -> Int? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "offset" })?
            .value
            .flatMap(Int.init)
    }

    // MARK: - Date / URL Helpers

    /// ISO8601 tarih stringini Date'e çevirir.
    static func parseNetDate(from string: String?) -> Date? {
        guard let string else { return nil }

        let isoFrac = ISO8601DateFormatter()
        isoFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = isoFrac.date(from: string) { return d }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: string) { return d }

        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return f.date(from: string)
    }

    /// Kullanıcıya okunabilir tarih metni üretir.
    static func formatNetDate(_ date: Date?) -> String {
        guard let date else { return "Tarih Yok" }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = .current
        displayFormatter.timeZone = .current
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }

    /// URL stringini güvenli biçimde oluşturur.
    static func sanitizeURLString(_ string: String?) -> URL? {
        guard let string else { return nil }
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return URL(string: trimmed)
    }
}
