import Foundation

// MARK: - Widget Loader

enum WidgetLoadError: Error, CustomStringConvertible {
    case invalidExtension
    case fileNotFound
    case dataFormat
    case missingRequiredField(String)
    case parsingFailed(Error)
    
    var description: String {
        switch self {
        case .invalidExtension:
            return "File extension is not '.wg'"
        case .fileNotFound:
            return "File not found."
        case .dataFormat:
            return "Failed to parse data format. Expecting JSON dictionary."
        case .missingRequiredField(let key):
            return "Missing required field: \(key)"
        case .parsingFailed(let err):
            return "Parsing error: \(err)"
        }
    }
}

class WidgetLoader {
    // MARK: Customization Points
    static let requiredFields: [String] = ["name"]

    static func validate(_ dict: [String: Any]) throws {
        for key in requiredFields {
            if dict[key] == nil {
                throw WidgetLoadError.missingRequiredField(key)
            }
        }
        // Add more validations if needed
    }
    
    // MARK: - Synchronous Widget Loading (Result-based)
    static func loadWidget(from url: URL) -> Result<Widget, WidgetLoadError> {
        guard url.pathExtension.lowercased() == "wg" else { return .failure(.invalidExtension) }
        do {
            guard FileManager.default.fileExists(atPath: url.path) else {
                return .failure(.fileNotFound)
            }
            let data = try Data(contentsOf: url)
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return .failure(.dataFormat)
            }
            try validate(dict)
            // Convert configuration values to String only
            let config = dict.compactMapValues { $0 as? String }
            
            let name = dict["name"] as? String ?? "Unnamed Widget"
            let description = dict["description"] as? String
            
            let widget = Widget(name: name, configuration: config, description: description)
            return .success(widget)
        } catch let err as WidgetLoadError {
            return .failure(err)
        } catch {
            return .failure(.parsingFailed(error))
        }
    }
    
    // MARK: - Async Support (Swift 5.5+)
    @available(macOS 12.0, iOS 15.0, *)
    static func loadWidgetAsync(from url: URL) async -> Result<Widget, WidgetLoadError> {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: loadWidget(from: url))
            }
        }
    }
    
    // MARK: - Bulk Loading & Sorting
    static func loadWidgets(from urls: [URL]) -> [Widget] {
        // Only return successfully loaded widgets
        let widgets = urls.compactMap {
            if case .success(let widget) = loadWidget(from: $0) {
                return widget
            }
            return nil
        }
        return widgets.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    // MARK: - Load All Widgets from Folder
    static func loadAllWidgets(in folder: URL) -> [Widget] {
        guard let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
        else { return [] }
        let wgFiles = files.filter { $0.pathExtension.lowercased() == "wg" }
        return loadWidgets(from: wgFiles)
    }
}

// MARK: - Example Usage

/*
let url = URL(fileURLWithPath: "/path/to/widget.wg")
switch WidgetLoader.loadWidget(from: url) {
case .success(let widget):
    print("Loaded widget: \(widget.name)")
case .failure(let err):
    print("Failed: \(err)")
}

let all = WidgetLoader.loadAllWidgets(in: widgetsFolderURL)
*/
