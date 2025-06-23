import Combine
import Foundation

class WidgetCenterViewModel: ObservableObject {
    @Published var widgets: [Widget] = []
    @Published var selectedWidget: Widget? = nil

    func addWidget(from url: URL) {
        switch WidgetLoader.loadWidget(from: url) {
        case .success(let widget):
            widgets.append(widget)
        case .failure:
            break // Optionally handle the error here
        }
    }

    func removeWidget(_ widget: Widget) {
        widgets.removeAll { $0.id == widget.id }
    }

    public func refreshWidgets() {
        objectWillChange.send()
    }
}
