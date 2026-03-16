import AppKit

enum CRTEffects {
    static func drawGlow(ctx: CGContext, rect: CGRect, intensity: Double) {
        let glowColor = NSColor(white: 0.7, alpha: intensity * 0.4).cgColor
        let coreColor = NSColor(white: 0.7, alpha: intensity).cgColor

        ctx.saveGState()
        ctx.setShadow(offset: .zero, blur: 15, color: glowColor)
        ctx.setFillColor(coreColor)
        ctx.fill(rect)
        ctx.restoreGState()

        ctx.setFillColor(coreColor)
        ctx.fill(rect)
    }
}
