import AppKit

final class OverlayController {
    private var panels: [OverlayPanel] = []
    private var animationViews: [CRTShutdownView] = []
    private let monitorIndex: Int

    var isActive: Bool { !panels.isEmpty }

    init(monitorIndex: Int) {
        self.monitorIndex = monitorIndex
    }

    func toggle() {
        if isActive {
            hide()
        } else {
            show()
        }
    }

    private func show() {
        guard let screens = MonitorManager.targetScreens(monitorIndex: monitorIndex),
              !screens.isEmpty else {
            NSSound.beep()
            return
        }

        for screen in screens {
            let overlay = OverlayPanel(screen: screen)
            overlay.backgroundColor = .clear
            panels.append(overlay)

            let crtView = CRTShutdownView(frame: overlay.contentView!.bounds)
            crtView.autoresizingMask = [.width, .height]
            overlay.contentView?.addSubview(crtView)
            animationViews.append(crtView)

            overlay.orderFrontRegardless()

            crtView.startAnimation { [weak crtView, weak overlay] in
                crtView?.removeFromSuperview()
                overlay?.backgroundColor = .black
            }
        }
    }

    private func hide() {
        for view in animationViews {
            view.stopAnimation()
        }
        animationViews.removeAll()

        for panel in panels {
            panel.close()
        }
        panels.removeAll()
    }
}
