import Foundation

class WidgetLoader {
    static func loadWidget(from url: URL) -> Widget? {
        guard url.pathExtension.lowercased() == "wg" else { return nil }
        do {
            let data = try Data(contentsOf: url)
            if let dict = try JSONSerialization.jsonObject(with: data) as? [String: String] {
                let name = dict["name"] ?? "Unnamed Widget"
                return Widget(name: name, configuration: dict, description: dict["description"])
            }
        } catch {
            print("Failed to parse .wg file: \(error)")
        }
        return nil
    }
}
