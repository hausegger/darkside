import AppKit

final class OverlayController {
    private var panel: OverlayPanel?
    private let monitorIndex: Int

    var isActive: Bool { panel != nil }

    init(monitorIndex: Int) {
        self.monitorIndex = monitorIndex
    }

    func toggle() {
        if panel != nil {
            hide()
        } else {
            show()
        }
    }

    private func show() {
        guard let screen = MonitorManager.targetScreen(monitorIndex: monitorIndex) else {
            NSSound.beep()
            return
        }

        let overlay = OverlayPanel(screen: screen)
        overlay.orderFrontRegardless()
        panel = overlay
    }

    private func hide() {
        panel?.close()
        panel = nil
    }
}
