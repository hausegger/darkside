import AppKit

final class OverlayController {
    private var panels: [OverlayPanel] = []
    private var animationViews: [CRTShutdownView] = []
    private var closingPanels: [OverlayPanel] = []
    private var startupViews: [CRTStartupView] = []
    private let monitor: Int

    var isActive: Bool { !panels.isEmpty || !closingPanels.isEmpty }

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

            guard let contentView = overlay.contentView else { continue }
            let crtView = CRTShutdownView(frame: contentView.bounds)
            crtView.autoresizingMask = [.width, .height]
            contentView.addSubview(crtView)
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

        // If already closing from a previous hide(), force-close those panels
        for view in startupViews {
            view.stopAnimation()
        }
        startupViews.removeAll()
        for panel in closingPanels {
            panel.close()
        }
        closingPanels.removeAll()

        closingPanels = panels
        panels.removeAll()

        guard !closingPanels.isEmpty else { return }

        for panel in closingPanels {
            panel.backgroundColor = .clear

            guard let contentView = panel.contentView else {
                panel.close()
                continue
            }
            let startupView = CRTStartupView(frame: contentView.bounds)
            startupView.autoresizingMask = [.width, .height]
            contentView.addSubview(startupView)
            startupViews.append(startupView)

            let displayID = panel.screen.map { MonitorManager.screenDisplayID($0) } ?? CGMainDisplayID()
            startupView.startAnimation(displayID: displayID) { [weak self, weak startupView, weak panel] in
                startupView?.removeFromSuperview()
                panel?.close()
                if let self, let panel {
                    self.closingPanels.removeAll { $0 === panel }
                }
                if let self, let startupView {
                    self.startupViews.removeAll { $0 === startupView }
                }
            }
        }
    }
}
