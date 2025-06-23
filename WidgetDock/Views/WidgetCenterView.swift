import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct WidgetCenterView: View {
    @ObservedObject var viewModel: WidgetCenterViewModel
    @State private var showingFileImporter = false
    @State private var fileImportError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("WidgetDock")
                .font(.largeTitle).bold()
                .accessibilityAddTraits(.isHeader)
                .padding(.top)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.widgets.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "apps.iphone")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No widgets yet.\nAdd a .wg file to get started!")
                            .multilineTextAlignment(.center)
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                Spacer()
            } else {
                List {
                    ForEach(viewModel.widgets) { widget in
                        WidgetListRowView(widget: widget)
                            .contextMenu {
                                Button("Remove") {
                                    viewModel.removeWidget(widget)
                                }
                            }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.inset)
                .frame(minHeight: 220)
            }

            Divider().padding(.top, 6).padding(.bottom, 4)

            HStack {
                Spacer()
                Button {
                    openMainWindow()
                    // Optional: auch den FileImporter anzeigen
                    // showingFileImporter = true
                } label: {
                    Label("Add Widget", systemImage: "plus")
                        .font(.body.weight(.medium))
                }
                .padding(8)
                .background(Color.secondary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityLabel("Add a new widget from .wg file")
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
        .frame(width: 350, height: 440)
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [UTType(filenameExtension: "wg")!],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let url = try result.get().first else { return }
                viewModel.addWidget(from: url)
            } catch {
                fileImportError = "Could not import the widget file."
            }
        }
        .alert(item: $fileImportError) { err in
            Alert(
                title: Text("Import Error"),
                message: Text(err),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    func delete(at offsets: IndexSet) {
        for idx in offsets {
            let widget = viewModel.widgets[idx]
            viewModel.removeWidget(widget)
        }
    }
}

// MARK: - Open Main Window

func openMainWindow() {
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
        styleMask: [.titled, .closable, .resizable],
        backing: .buffered,
        defer: false
    )
    window.center()
    window.title = "Main Window"
    window.contentView = NSHostingView(rootView: MainWindowView(viewModel: WidgetCenterViewModel()))
    window.makeKeyAndOrderFront(nil)
}

// MARK: - Error Handling

extension String: Identifiable {
    public var id: String { self }
}

