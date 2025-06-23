import SwiftUI
import Combine
import UniformTypeIdentifiers

private let customBG = Color(red: 30/255, green: 30/255, blue: 30/255)

// MARK: - MAIN WINDOW

struct MainWindowView: View {
    @ObservedObject var viewModel: WidgetCenterViewModel
    @State private var selectedTab = Tab.widgets
    @State private var alertMessage: String?

    enum Tab: String, CaseIterable, Identifiable {
        case widgets, store, settings, about
        var id: Self { self }
        var label: String {
            switch self {
                case .widgets: return "Widgets"
                case .store: return "Store"
                case .settings: return "Settings"
                case .about: return "About"
            }
        }
        var icon: String {
            switch self {
                case .widgets: return "rectangle.grid.2x2"
                case .store: return "cart.fill"
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
            
            StoreView()
                .tabItem {
                    Label(Tab.store.label, systemImage: Tab.store.icon)
                }
                .tag(Tab.store)
            
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
        .background(customBG)
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
                .background(customBG)
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
                .background(customBG)
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

// MARK: - STORE
struct StoreView: View {
    struct StoreWidget: Identifiable {
        let id = UUID()
        let name: String
        let description: String
        let imageName: String
    }

    @State private var searchText: String = ""
    
    private let widgets: [StoreWidget] = [
        StoreWidget(name: "Weather Widget", description: "Get the latest weather updates.", imageName: "cloud.sun.fill"),
        StoreWidget(name: "Calendar Widget", description: "Keep track of your events.", imageName: "calendar"),
        StoreWidget(name: "News Widget", description: "Stay informed with news headlines.", imageName: "newspaper.fill"),
        StoreWidget(name: "Fitness Widget", description: "Monitor your daily activity.", imageName: "heart.fill"),
        StoreWidget(name: "Stock Widget", description: "Track your favorite stocks.", imageName: "chart.line.uptrend.xyaxis"),
        StoreWidget(name: "Music Widget", description: "Control your music playback.", imageName: "music.note.list"),
        StoreWidget(name: "Reminder Widget", description: "Never forget your tasks.", imageName: "bell.fill"),
        StoreWidget(name: "Quotes Widget", description: "Daily inspiration at a glance.", imageName: "quote.bubble.fill"),
        StoreWidget(name: "Photo Widget", description: "Showcase your favorite photos.", imageName: "photo.fill.on.rectangle.fill")
    ]
    
    var filteredWidgets: [StoreWidget] {
        if searchText.isEmpty {
            return widgets
        } else {
            return widgets.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 20)], spacing: 28) {
                ForEach(filteredWidgets) { widget in
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color(NSColor.windowBackgroundColor).opacity(0.6))
                            )
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 6)
                        
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 96, height: 96)
                                
                                Image(systemName: widget.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                            }
                            
                            Text(widget.name)
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.75)
                            
                            Text(widget.description)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .padding(.horizontal, 8)
                            
                            Button(action: {
                                // Placeholder action for "Get" button
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Get")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 16)
                            .padding(.bottom, 14)
                        }
                        .padding(.top, 22)
                        .padding(.horizontal, 12)
                    }
                    .frame(minHeight: 280)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .searchable(text: $searchText, prompt: "Search widgets")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(customBG)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(customBG)
    }
}

// MARK: - ABOUT
struct AboutView: View {
    var body: some View {
        VStack {
            Spacer(minLength: 28)
            ZStack {
                VStack(spacing: 30) {
                    // App Icon & Title
                    VStack(spacing: 10) {
                        Image("AppIconInApp")
                            .resizable()
                            .frame(width: 96, height: 96)
                            .cornerRadius(24)
                            .shadow(radius: 12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(.secondary.opacity(0.15), lineWidth: 2)
                            )
                        Text("WidgetDock")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Text("Version 1.0")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    // About Description
                    Text("Your all-in-one dashboard for managing, importing, and personalizing widgets. Made with ❤️ in SwiftUI.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)

                    Divider()

                    // Important Links
                    VStack(spacing: 10) {
                        HStack(spacing:28) {
                            Link(destination: URL(string: "https://velis.me")!) {
                                Label("Support", systemImage: "questionmark.circle")
                            }
                            Link(destination: URL(string: "https://github.com/widgetdock")!) {
                                Label("GitHub", systemImage: "link")
                            }
                        }
                        .font(.system(size: 16, weight: .medium))
                    }

                    // Download More Widgets
                    VStack(spacing: 7) {
                        Text("Looking for more widgets?")
                            .font(.headline)
                        Link(destination: URL(string: "https://widgetdock.store")!) {
                            Label("Browse WidgetDock Store", systemImage: "cart")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 9)
                                .background(Color.accentColor.opacity(0.18))
                                .foregroundStyle(Color.accentColor)
                                .cornerRadius(14)
                        }
                    }
                    .padding(.top, 8)

                    Divider()

                    // Footer
                    Text("© \(Calendar.current.component(.year, from: .now)) WidgetDock")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 6)
                }
                .padding(.vertical, 38)
                .padding(.horizontal, 44)
            }
            .padding(.horizontal, 32)
            Spacer(minLength: 30)
                .background(customBG)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(customBG)
        }
    }
}

struct MainWindowView_Previews: PreviewProvider {
    static var previews: some View {
        MainWindowView(viewModel: WidgetCenterViewModel())
    }
}
