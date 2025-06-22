import Foundation

struct Widget: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var configuration: [String: String]
    var description: String?

    init(name: String, configuration: [String: String], description: String? = nil) {
        self.id = UUID()
        self.name = name
        self.configuration = configuration
        self.description = description
    }
}
