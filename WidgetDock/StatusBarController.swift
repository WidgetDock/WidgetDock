import Cocoa
import SwiftUI

class StatusBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover

    init(viewModel: WidgetCenterViewModel) {
        popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 350, height: 500)
        popover.contentViewController = NSHostingController(rootView: WidgetCenterView(viewModel: viewModel))

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: "WidgetDock")
            button.image?.isTemplate = true // Optional: ensures proper appearance in dark/light mode
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}

