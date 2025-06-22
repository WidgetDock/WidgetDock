import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var widgetCenterViewModel = WidgetCenterViewModel()
    var statusBarController: StatusBarController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController(viewModel: widgetCenterViewModel)
    }
}
