import Cocoa
import SwiftUI

class OverlayWindow: NSWindow {
    init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.level = .floating
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
    }
    
    override var canBecomeKey: Bool {
        return false
    }
    
    override var canBecomeMain: Bool {
        return false
    }
    
    func showGhostText(_ text: String, at screenRect: CGRect) {
        // Adjust coordinate system. AXUIElement returns top-left based coordinates,
        // while NSWindow uses bottom-left. We need to flip the Y coordinate.
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(CGPoint(x: screenRect.midX, y: NSScreen.screens[0].frame.height - screenRect.midY)) }) ?? NSScreen.main else {
            return
        }
        
        let flippedY = screen.frame.height - screenRect.origin.y - screenRect.height
        // The rect provided is the bounds of the character before the cursor.
        // We want to place the window immediately to the right of that character.
        let windowOrigin = CGPoint(x: screenRect.maxX, y: flippedY)
        
        // We make the window large enough to hold text, but since we ignore mouse events, it doesn't block clicks.
        let windowFrame = CGRect(x: windowOrigin.x, y: windowOrigin.y, width: 400, height: 30)
        
        self.setFrame(windowFrame, display: true)
        
        // Update SwiftUI View
        self.contentView = NSHostingView(rootView: GhostTextView(text: text))
        
        if !self.isVisible {
            self.orderFront(nil)
        }
    }
    
    func hide() {
        self.orderOut(nil)
    }
}
