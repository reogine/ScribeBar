import Cocoa
import ApplicationServices

class AXManager: ObservableObject {
    static let shared = AXManager()
    
    @Published var isTrusted: Bool = false
    @Published var focusedElement: AXUIElement?
    
    private var observer: AXObserver?
    private var currentAppElement: AXUIElement?
    
    init() {
        checkPermissions()
        if isTrusted {
            setupObservers()
        }
    }
    
    func checkPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        isTrusted = AXIsProcessTrustedWithOptions(options)
    }
    
    func setupObservers() {
        // Observe app activations to attach to the new frontmost app
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleAppActivation(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
        
        // Initial setup for whatever app is currently frontmost
        if let frontmost = NSWorkspace.shared.frontmostApplication {
            attachObserver(to: frontmost)
        }
    }
    
    @objc private func handleAppActivation(_ notification: Notification) {
        guard let appInfo = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
        attachObserver(to: appInfo)
    }
    
    private func attachObserver(to app: NSRunningApplication) {
        // Clean up old observer
        if let observer = observer {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(observer), CFRunLoopMode.defaultMode)
            self.observer = nil
        }
        
        let appPid = app.processIdentifier
        let appElement = AXUIElementCreateApplication(appPid)
        self.currentAppElement = appElement
        
        var newObserver: AXObserver?
        let error = AXObserverCreate(appPid, observerCallback, &newObserver)
        
        guard error == .success, let unwrappedObserver = newObserver else {
            print("Failed to create AXObserver for PID: \(appPid)")
            return
        }
        
        self.observer = unwrappedObserver
        
        // Register for focused element changes
        AXObserverAddNotification(unwrappedObserver, appElement, kAXFocusedUIElementChangedNotification as CFString, Unmanaged.passUnretained(self).toOpaque())
        // Register for value changes (typing)
        AXObserverAddNotification(unwrappedObserver, appElement, kAXValueChangedNotification as CFString, Unmanaged.passUnretained(self).toOpaque())
        // Register for selected text changes (cursor movement)
        AXObserverAddNotification(unwrappedObserver, appElement, kAXSelectedTextChangedNotification as CFString, Unmanaged.passUnretained(self).toOpaque())
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(unwrappedObserver), CFRunLoopMode.defaultMode)
        
        // Fetch the initial focused element
        updateFocusedElement()
    }
    
    private func updateFocusedElement() {
        guard let systemWideElement = AXUIElementCreateSystemWide() as AXUIElement? else { return }
        
        var focusedElementValue: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElementValue)
        
        if error == .success {
            let element = focusedElementValue as! AXUIElement
            DispatchQueue.main.async {
                self.focusedElement = element
                NotificationCenter.default.post(name: .focusedElementChanged, object: element)
            }
        }
    }
    
    func handleNotification(_ notification: CFString, element: AXUIElement) {
        DispatchQueue.main.async {
            if notification == kAXFocusedUIElementChangedNotification as CFString {
                self.focusedElement = element
                NotificationCenter.default.post(name: .focusedElementChanged, object: element)
            } else if notification == kAXValueChangedNotification as CFString || notification == kAXSelectedTextChangedNotification as CFString {
                NotificationCenter.default.post(name: .textOrCursorChanged, object: element)
            }
        }
    }
}

// C-style callback for AXObserver
private func observerCallback(observer: AXObserver, element: AXUIElement, notification: CFString, refcon: UnsafeMutableRawPointer?) {
    guard let refcon = refcon else { return }
    let manager = Unmanaged<AXManager>.fromOpaque(refcon).takeUnretainedValue()
    manager.handleNotification(notification, element: element)
}

extension Notification.Name {
    static let focusedElementChanged = Notification.Name("focusedElementChanged")
    static let textOrCursorChanged = Notification.Name("textOrCursorChanged")
}
