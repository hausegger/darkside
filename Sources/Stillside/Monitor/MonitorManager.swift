import AppKit

final class MonitorManager {
    /// Returns the target screen for the given monitor value.
    /// -1 = non-active (screen without cursor), positive = CGDirectDisplayID.
    static func targetScreens(monitor: Int) -> [NSScreen]? {
        if monitor == StillsideConfig.nonActiveMonitor {
            return nonActiveScreens()
        }
        let displayID = CGDirectDisplayID(monitor)
        let screens = NSScreen.screens
        guard let screen = screens.first(where: { screenDisplayID($0) == displayID }) else { return nil }
        return [screen]
    }

    static func screenDisplayID(_ screen: NSScreen) -> CGDirectDisplayID {
        screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0
    }

    /// Returns the screen that does NOT contain the mouse cursor.
    /// With 2 monitors, this is "the other one." With 1 monitor, returns nil.
    private static func nonActiveScreens() -> [NSScreen]? {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let nonActive = screens.filter { !NSMouseInRect(mouseLocation, $0.frame, false) }
        return nonActive.isEmpty ? nil : nonActive
    }

    /// Returns a labeled list of all monitors for the picker.
    static func listMonitors() -> [(value: Int, name: String, label: String)] {
        var result: [(value: Int, name: String, label: String)] = []
        result.append((value: StillsideConfig.nonActiveMonitor, name: "Non-active", label: "Non-active (screen without cursor)"))
        for screen in NSScreen.screens {
            let displayID = screenDisplayID(screen)
            let isPrimary = (screen == NSScreen.main)
            let suffix = isPrimary ? " (primary)" : ""
            result.append((value: Int(displayID), name: screen.localizedName, label: "\(screen.localizedName)\(suffix)"))
        }
        return result
    }
}
