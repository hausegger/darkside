import AppKit

final class OverlayController {
    private var panels: [OverlayPanel] = []
    private var animationViews: [CRTShutdownView] = []
    private let monitor: Int

    var isActive: Bool { !panels.isEmpty }

    init(monitor: Int) {
        self.monitor = monitor
    }

    func toggle() {
        if isActive {
            hide()
        } else {
            show() 
        }
    }

    private func show() {
        guard let screens = MonitorManager.targetScreens(monitor: monitor),
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

            let displayID = MonitorManager.screenDisplayID(screen)
            crtView.startAnimation(displayID: displayID) { [weak crtView, weak overlay] in
                crtView?.removeFromSuperview()
                overlay?.backgroundColor = .black
            }
        }
    }

    func hide() {
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
