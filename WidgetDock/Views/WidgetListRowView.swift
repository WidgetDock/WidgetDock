import SwiftUI

struct WidgetListRowView: View {
    let widget: Widget

    var body: some View {
        VStack(alignment: .leading) {
            Text(widget.name)
                .font(.headline)
            if let description = widget.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            if !widget.configuration.isEmpty {
                Text(widget.configuration.map { "\($0.key): \($0.value)" }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
