import SwiftUI

struct WidgetDetailView: View {
    let widget: Widget

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(widget.name)
                .font(.largeTitle)
                .padding(.bottom)

            Text(widget.description ?? "")
                .padding(.bottom)

            ForEach(Array(widget.configuration.keys), id: \.self) { key in
                HStack {
                    Text(key)
                        .bold()
                    Spacer()
                    Text(widget.configuration[key] ?? "")
                }
            }
            Spacer()
        }
        .padding()
    }
}
