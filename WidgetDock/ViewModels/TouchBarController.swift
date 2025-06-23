import Cocoa

class TouchBarController: NSObject, NSTouchBarDelegate {
    static let touchBarButtonIdentifier = NSTouchBarItem.Identifier("com.widgetcenter.touchbar.add")

    weak var target: AnyObject?
    var action: Selector?

    init(target: AnyObject?, action: Selector?) {
        self.target = target
        self.action = action
    }

    func makeTouchBar() -> NSTouchBar {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.fixedSpaceSmall, Self.touchBarButtonIdentifier, .flexibleSpace]
        return touchBar
    }

    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        if identifier == Self.touchBarButtonIdentifier {
            let button = NSButton(title: "Add Widget", target: target, action: action)
            button.bezelColor = .systemBlue
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = button
            return item
        }
        return nil
    }
}
