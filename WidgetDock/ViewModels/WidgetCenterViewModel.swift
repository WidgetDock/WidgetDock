import Combine
import Foundation

class WidgetCenterViewModel: ObservableObject {
    @Published var widgets: [Widget] = []
    @Published var selectedWidget: Widget? = nil

    func addWidget(from url: URL) {
        if let widget = WidgetLoader.loadWidget(from: url) {
            widgets.append(widget)
        }
    }

    func removeWidget(_ widget: Widget) {
        widgets.removeAll { $0.id == widget.id }
    }
}
