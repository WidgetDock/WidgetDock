import Foundation

/// A model representing a configurable Widget.
struct Widget: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var configuration: [String: String]
    var description: String?
    
    /// Ensures configuration keys are always sorted for consistency.
    private static func sortedConfig(_ config: [String: String]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: config.sorted { $0.key < $1.key })
    }
    
    /// Main initializer
    init(id: UUID = UUID(), name: String, configuration: [String: String], description: String? = nil) {
        self.id = id
        self.name = name
        self.configuration = Self.sortedConfig(configuration)
        self.description = description
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case id, name, configuration, description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let config = try container.decode([String: String].self, forKey: .configuration)
        configuration = Self.sortedConfig(config)
        description = try container.decodeIfPresent(String.self, forKey: .description)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        // Always encode sorted keys!
        try container.encode(Self.sortedConfig(configuration), forKey: .configuration)
        try container.encodeIfPresent(description, forKey: .description)
    }
}
