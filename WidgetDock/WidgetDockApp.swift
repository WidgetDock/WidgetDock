import SwiftUI

@main
struct WidgetDockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup("WidgetDock") {
            MainWindowView(viewModel: appDelegate.widgetCenterViewModel)
        }
    }
}
