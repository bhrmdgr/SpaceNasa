//
//  Flight.swift
//  SpaceNasaAPI
//
//  Created by Behram Doğru on 6.10.2025.
//


import Foundation

public struct FlightResults: Decodable, Sendable {
    public let count: Int?
    public let next: URL?
    public let previous: URL?
    public let results: [Flight]
}

public struct FlightStatus: Decodable, Sendable {
    public let id: Int?
    public let name: String?
    public let abbrev: String?
    public let description: String?
}

public struct Flight: Decodable, Sendable {
    //MARK: Listeleme
    public let id: String
    public let name: String
    public let net: String?
    public let status: FlightStatus?
    public private(set) var pad: String?
    public private(set) var location: String?
    public let image: String?
    public private(set) var lspName: String?

    //MARK: Detay
    public private(set) var providerType: String?
    public private(set) var countryCode: String?

    public private(set) var rocketFullName: String?
    public private(set) var rocketFamily: String?
    public private(set) var rocketVariant: String?

    public private(set) var missionName: String?
    public private(set) var missionType: String?
    public private(set) var missionOrbit: String?
    public private(set) var missionDescription: String?

    private enum CodingKeys: String, CodingKey {
        case id, name, net, status, image
        case pad
        case location
        case lspName = "lsp_name"
        case launchServiceProvider = "launch_service_provider"
        case rocket
        case mission
    }

    private enum ProviderKeys: String, CodingKey { case name, type }
    private enum RocketKeys: String, CodingKey { case configuration }
    private enum RocketConfigKeys: String, CodingKey { case fullName = "full_name", family, variant }
    private enum MissionKeys: String, CodingKey { case name, type, description, orbit }
    private enum OrbitKeys: String, CodingKey { case name, abbrev }
    private enum PadObjectKeys: String, CodingKey { case name, location }
    private enum LocationObjKeys: String, CodingKey { case name, countryCode = "country_code" }

    // Custom init: string/obje varyasyonlarını destekler
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id     = try container.decode(String.self, forKey: .id)
        self.name   = try container.decode(String.self, forKey: .name)
        self.net    = try? container.decode(String.self, forKey: .net)
        self.status = try? container.decode(FlightStatus.self, forKey: .status)
        self.image  = try? container.decode(String.self, forKey: .image)

        //MARK: LSP
        self.lspName = try? container.decode(String.self, forKey: .lspName)
        if let provider = try? container.nestedContainer(keyedBy: ProviderKeys.self, forKey: .launchServiceProvider) {
            if self.lspName == nil { self.lspName = try? provider.decodeIfPresent(String.self, forKey: .name) }
            self.providerType = try? provider.decodeIfPresent(String.self, forKey: .type)
        }

        // MARK: Pad
        if let padString = try? container.decode(String.self, forKey: .pad) {
            self.pad = padString
        } else if let padObj = try? container.nestedContainer(keyedBy: PadObjectKeys.self, forKey: .pad) {
            self.pad = try? padObj.decodeIfPresent(String.self, forKey: .name)
            if let loc = try? padObj.nestedContainer(keyedBy: LocationObjKeys.self, forKey: .location) {
                let locName = try? loc.decodeIfPresent(String.self, forKey: .name)
                if let ln = locName, (self.location == nil || self.location?.isEmpty == true) {
                    self.location = ln
                }
                self.countryCode = try? loc.decodeIfPresent(String.self, forKey: .countryCode)
            }
        }

        // MARK: Location
        if self.location == nil {
            self.location = try? container.decodeIfPresent(String.self, forKey: .location)
        }

        // MARK: Rocket
        if let rocket = try? container.nestedContainer(keyedBy: RocketKeys.self, forKey: .rocket),
           let config = try? rocket.nestedContainer(keyedBy: RocketConfigKeys.self, forKey: .configuration) {
            self.rocketFullName = try? config.decodeIfPresent(String.self, forKey: .fullName)
            self.rocketFamily   = try? config.decodeIfPresent(String.self, forKey: .family)
            self.rocketVariant  = try? config.decodeIfPresent(String.self, forKey: .variant)
        }

        // MARK: Mission
        if let mission = try? container.nestedContainer(keyedBy: MissionKeys.self, forKey: .mission) {
            self.missionName        = try? mission.decodeIfPresent(String.self, forKey: .name)
            self.missionType        = try? mission.decodeIfPresent(String.self, forKey: .type)
            self.missionDescription = try? mission.decodeIfPresent(String.self, forKey: .description)
            if let orbit = try? mission.nestedContainer(keyedBy: OrbitKeys.self, forKey: .orbit) {
                self.missionOrbit = (try? orbit.decodeIfPresent(String.self, forKey: .abbrev))
                    ?? (try? orbit.decodeIfPresent(String.self, forKey: .name))
            }
        }
    }
}
