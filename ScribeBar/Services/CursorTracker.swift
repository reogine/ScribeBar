import Cocoa
import ApplicationServices

struct CursorContext {
    let textBeforeCursor: String
    let cursorScreenRect: CGRect
}

class CursorTracker {
    static let shared = CursorTracker()
    
    func getContext(from element: AXUIElement) -> CursorContext? {
        var valueRef: CFTypeRef?
        let valueError = AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &valueRef)
        
        var selectedRangeRef: CFTypeRef?
        let rangeError = AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &selectedRangeRef)
        
        guard valueError == .success, rangeError == .success else { return nil }
        
        guard let text = valueRef as? String else { return nil }
        
        // Extract CFRange
        // swiftlint:disable:next force_cast
        let selectedRangeValue = selectedRangeRef as! AXValue
        var selectedRange = CFRange()
        guard AXValueGetValue(selectedRangeValue, .cfRange, &selectedRange) else { return nil }
        
        // We only care about insertion point (length 0) or the start of the selection
        let cursorIndex = selectedRange.location
        
        let textBeforeCursor: String
        if cursorIndex <= text.utf16.count {
            let index = text.utf16.index(text.utf16.startIndex, offsetBy: cursorIndex)
            textBeforeCursor = String(text.utf16[..<index]) ?? ""
        } else {
            textBeforeCursor = text
        }
        
        // Get Bounds for the cursor range
        var boundsRef: CFTypeRef?
        // We ask for the bounds of a length 1 range right at the cursor, or length 0 if supported.
        // Some apps require length > 0 to return bounds.
        var rangeForBounds = CFRange(location: max(0, cursorIndex - 1), length: 1)
        guard let axRangeValue = AXValueCreate(.cfRange, &rangeForBounds) else { return nil }
        
        let boundsError = AXUIElementCopyParameterizedAttributeValue(element, kAXBoundsForRangeParameterizedAttribute as CFString, axRangeValue, &boundsRef)
        
        var screenRect = CGRect.zero
        if boundsError == .success, let boundsValue = boundsRef as! AXValue? {
            AXValueGetValue(boundsValue, .cgRect, &screenRect)
        }
        
        // If we queried the character BEFORE the cursor, we should shift the X coordinate by its width.
        // For simplicity right now, we will return the rect. The overlay window logic will refine it.
        
        return CursorContext(textBeforeCursor: textBeforeCursor, cursorScreenRect: screenRect)
    }
}
