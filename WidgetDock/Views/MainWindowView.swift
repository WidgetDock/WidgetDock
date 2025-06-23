import SwiftUI
import Combine
import UniformTypeIdentifiers


// MARK: - MAIN WINDOW

struct MainWindowView: View {
    @ObservedObject var viewModel: WidgetCenterViewModel
    @State private var selectedTab = Tab.widgets
    @State private var alertMessage: String?

    enum Tab: String, CaseIterable, Identifiable {
        case widgets, settings, about
        var id: Self { self }
        var label: String {
            switch self {
                case .widgets: return "Widgets"
                case .settings: return "Settings"
                case .about: return "About"
            }
        }
        var icon: String {
            switch self {
                case .widgets: return "rectangle.grid.2x2"
                case .settings: return "gearshape"
                case .about: return "info.circle"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            widgetsTab
                .tabItem {
                    Label(Tab.widgets.label, systemImage: Tab.widgets.icon)
                }
                .tag(Tab.widgets)
            
            SettingsView()
                .tabItem {
                    Label(Tab.settings.label, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
            
            AboutView()
                .tabItem {
                    Label(Tab.about.label, systemImage: Tab.about.icon)
                }
                .tag(Tab.about)
        }
        .alert(item: $alertMessage) { msg in
            Alert(title: Text("Notice"), message: Text(msg), dismissButton: .default(Text("OK")))
        }
        .animation(.easeInOut, value: selectedTab)
        .frame(minWidth: 950, minHeight: 560)
    }
    
    var widgetsTab: some View {
        Group {
            if viewModel.widgets.isEmpty {
                // Show only Empty-State Centered
                VStack(spacing: 15) {
                    Spacer()
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No widgets yet. Import or create new widgets!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Button(action: addWidget) {
                        Label("Add Widget", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                    }
                    .padding(.top, 4)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.windowBackgroundColor).opacity(0.65))
            } else {
                NavigationSplitView {
                    VStack(spacing:0) {
                        HStack {
                            Text("Available Widgets")
                                .font(.headline)
                                .padding(.leading)
                            Spacer()
                            Button(action: addWidget) {
                                Label("Add", systemImage: "plus")
                            }
                            .keyboardShortcut("n", modifiers: [.command])
                            .help("Add Widget")
                            .padding(.trailing)
                        }
                        .padding(.vertical, 9)
                        Divider()
                        List(selection: $viewModel.selectedWidget) {
                            ForEach(viewModel.widgets) { widget in
                                HStack {
                                    Image(systemName: "rectangle")
                                        .foregroundColor(.secondary)
                                    VStack(alignment: .leading) {
                                        Text(widget.name).fontWeight(.semibold)
                                        Text(widget.description ?? "")
                                            .lineLimit(1)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .tag(widget)
                            }
                            .onDelete(perform: delete)
                        }
                        .listStyle(.inset(alternatesRowBackgrounds: true))
                    }
                    .background(.thinMaterial)
                } detail: {
                    if let selected = viewModel.selectedWidget {
                        WidgetDetailView(widget: selected)
                            .transition(.slide)
                    } else {
                        VStack {
                            Spacer()
                            Image(systemName: "rectangle.grid.2x2")
                                .font(.system(size: 64, weight: .thin))
                                .foregroundColor(.accentColor)
                            Text("Select a widget to see details")
                                .foregroundColor(.secondary)
                                .font(.title2)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .background(Color(.windowBackgroundColor))
            }
        }
    }
    
    // MARK: - Add & Delete Handlers
    func addWidget() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.title = "Select a .wg widget file"
        panel.allowedContentTypes = [.init(filenameExtension: "wg")!]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.addWidget(from: url)
            alertMessage = "Widget added: \(url.lastPathComponent)"
        } else {
            // optionally show "cancelled"
        }
        #endif
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { idx in
            let widget = viewModel.widgets[idx]
            viewModel.removeWidget(widget)
        }
    }
}

// MARK: - SETTINGS
struct SettingsView: View {
    @AppStorage("autoUpdate") private var autoUpdate: Bool = true
    @AppStorage("analyticsEnabled") private var analytics: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("General Preferences")) {
                Toggle("Enable Automatic Updates", isOn: $autoUpdate)
                    .help("Automatically update all widgets when new versions are available.")
                Toggle("Analytics & Crash Reporting", isOn: $analytics)
                    .help("Help improve WidgetCenter by sending anonymous usage data.")
            }
        }
        .padding(32)
        .frame(maxWidth: 560)
    }
}

// MARK: - ABOUT
struct AboutView: View {
    var body: some View {
        VStack(spacing: 28) {
            Image("AppIconInApp")
                .resizable()
                .frame(width: 92, height: 92)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.top, 24)
                .opacity(0.96)
            
            Text("**WidgetCenter**\nVersion 1.0")
                .font(.title)
            Text("WidgetCenter is your all-in-one dashboard for managing, importing, and personalizing widgets.\n\nMade with ❤️ in SwiftUI.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Divider()
            HStack(spacing:24) {
                Link(destination: URL(string: "https://yourcompany.com/support")!) {
                    Label("Support", systemImage: "questionmark.circle")
                }
                Link(destination: URL(string: "https://github.com/yourcompany/widgetcenter")!) {
                    Label("GitHub", systemImage: "link")
                }
            }
            .font(.subheadline)
            Spacer()
            Text("© \(Calendar.current.component(.year, from: .now)) WidgetDock")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)
        }
        .padding(.horizontal, 48)
    }
}

struct MainWindowView_Previews: PreviewProvider {
    static var previews: some View {
        MainWindowView(viewModel: WidgetCenterViewModel())
    }
}

